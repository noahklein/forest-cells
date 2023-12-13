package ngui

import "core:math/linalg"
import "core:fmt"
import "core:strings"
import "core:unicode/utf8"
import "core:reflect"
import "core:runtime"
import rl "vendor:raylib"

INF :: f32(1e7)

state : NGui

NGui :: struct {
    mouse: rl.Vector2, // Mouse position

    dragging: cstring,
    drag_offset: rl.Vector2,

    text_inputs: map[cstring]TextInput,
    active_input: cstring,
    last_keypress_time: f64,

    panels: map[cstring]Panel,
    panel: cstring, // Active panel
    panel_row, panel_column: int,
    column_widths: []f32,
}

init :: proc() {
    reserve(&state.panels, 16)
    reserve(&state.text_inputs, 16)
}

deinit :: proc() {
    delete(state.panels)
    for key, &ti in state.text_inputs {
        strings.builder_destroy(&ti.buf)
    }
    delete(state.text_inputs)
}

update :: proc() {
    using state;

    screen := rl.Vector2{f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
    mouse = linalg.clamp(rl.GetMousePosition(), 0, screen)

    if dragging != nil && rl.IsMouseButtonUp(.LEFT) {
        dragging = nil
    }

    if p, ok := &panels[dragging]; ok {
        pos := mouse + drag_offset
        p.rect.x = pos.x
        p.rect.y = pos.y
    }

    assert(len(state.panels) <= 32, "Using more than 32 panels, is this intentional?")
}

slider_rect :: proc(rect: rl.Rectangle, val: ^f32, $low, $high: f32) {
    #assert(low < high)
    pct := val^ / (high - low)

    slider_x := rect.x + pct * rect.width - SLIDER_WIDTH / 2 // Cursor should be in center of slider control
    slider_x  = clamp(slider_x, rect.x, rect.x + rect.width - SLIDER_WIDTH)
    slider_rect := rl.Rectangle{slider_x, rect.y, SLIDER_WIDTH, rect.height}

    key := fmt.ctprintf("%s#slider#%d-%d", state.panel, state.panel_row, state.panel_column)
    if rl.CheckCollisionPointRec(state.mouse, rect) && rl.IsMouseButtonPressed(.LEFT) {
        state.dragging = key
        state.drag_offset = {0, 0}
    }

    is_active := state.dragging == key
    if is_active {
        mouse_pct := (state.mouse.x - rect.x) / rect.width
        v := mouse_pct * (high - low)
        val^ = clamp(v, low, high)
    }

    is_hover := hovered(rect)

    rl.DrawRectangleRec({rect.x, rect.y, rect.width, rect.height}, dark_color(is_hover, is_active))
    rl.DrawRectangleRec(slider_rect, button_color(is_hover, is_active))
}

slider :: proc(val: ^f32, $low, $high: f32) {
    rect := flex_rect() or_else panic("Must be called between begin_panel() and end_panel()")
    slider_rect(rect, val, low, high)
}

button :: proc(label: cstring) -> bool {
    rect := flex_rect() or_else panic("Must be called between begin_panel() and end_panel()")
    return button_rect(rect, label)
}

button_rect :: proc(rect: rl.Rectangle, label: cstring) -> bool {
    hovered := rl.CheckCollisionPointRec(rl.GetMousePosition(), rect)

    rl.DrawRectangleRec(rect, button_color(hovered, hovered && rl.IsMouseButtonDown(.LEFT)))
    if label != nil {
        label_rect(rect, label, color = rl.WHITE, align = .Center)
    }

    return hovered && rl.IsMouseButtonReleased(.LEFT)
}


vec2 :: proc(v: ^rl.Vector2, min: f32 = -INF, max: f32 = INF, step: f32 = 0.1) {
    rect := flex_rect() or_else panic("Must be called between begin_panel() and end_panel()")
    rect.width /= 2

    first := rect
    f32_rect(first, &v.x, min, max, step)

    second := rect
    second.x += rect.width
    f32_rect(second, &v.y, min, max, step)

    // Divider line.
    divider := rl.Vector2{second.x, second.y + COMPONENT_PADDING.y}
    rl.DrawLineV(divider, divider + {0, rect.height - 2 * COMPONENT_PADDING.y}, rl.WHITE)
}

// Draggable f32 editor. Hold alt while dragging for finer control, hold shift to speed it up.
f32_rect :: proc(rect: rl.Rectangle, f: ^f32, min := -INF, max := INF, step: f32 = 0.1) {
    key := fmt.ctprintf("f32#%v", rect)
    press := pressed(rect)
    if press {
        state.dragging = key
        state.drag_offset = rl.Vector2{rect.x, rect.y} - state.mouse
    }
    dragging := state.dragging == key
    if dragging {
        slow_down: f32 = 0.1 if rl.IsKeyDown(.LEFT_ALT)   else 1.0
        speed_up : f32 = 10  if rl.IsKeyDown(.LEFT_SHIFT) else 1.0
        f^ += rl.GetMouseDelta().x * step * slow_down * speed_up
        f^ = clamp(f^, min, max)
    }

    rl.DrawRectangleRec(rect, button_color(hovered(rect), dragging, press))
    label_rect(rect, fmt.ctprintf("%.2f", f^), color = rl.WHITE, align = .Center)
}

radio_group :: proc($Enum: typeid, val: ^Enum) {
    rect := flex_rect() or_else panic("Must be called between begin_panel() and end_panel()")
    radio_group_rect(rect, Enum, val)
}

radio_group_rect :: proc(rect: rl.Rectangle, $Enum: typeid, val: ^Enum) {
    fields := reflect.enum_fields_zipped(Enum)
    fmt.assertf(len(fields) > 0, "enum_choice requires enum type with at least one member, enum = %v", typeid_of(Enum))

    btn_rect := rect
    btn_rect.width /= f32(len(fields))
    for field in fields {
        cstr := strings.clone_to_cstring(field.name, context.temp_allocator)
        if toggle_rect(btn_rect, cstr, val^ == Enum(field.value)) {
            val^ = Enum(field.value)
        }

        btn_rect.x += btn_rect.width
    }
}

toggle :: proc(label: cstring, selected: bool) -> bool {
    rect, _ := flex_rect()
    return toggle_rect(rect, label, selected)
}

// Like a checkbox, a button that can be pressed and unpressed. Does not manage its own state.
toggle_rect :: proc(rect: rl.Rectangle, label: cstring, selected: bool) -> bool {
    hover := hovered(rect)
    press := hover && rl.IsMouseButtonPressed(.LEFT)
    rl.DrawRectangleRec(rect, button_color(hover, selected, press))
    label_rect(rect, label, align = .Center)
    return press
}

@(require_results)
pressed :: #force_inline proc(rect: rl.Rectangle) -> bool {
    return rl.IsMouseButtonPressed(.LEFT) && hovered(rect)
}

@(require_results)
hovered :: #force_inline proc(rect: rl.Rectangle) -> bool {
    return rl.CheckCollisionPointRec(state.mouse, rect)
}

@(require_results)
padding :: #force_inline proc(rect: rl.Rectangle, pad: rl.Vector2) -> rl.Rectangle {
    return {
        rect.x + pad.x,
        rect.y + pad.y,
        rect.width  - 2 * pad.x,
        rect.height - 2 * pad.y,
    }
}

@(require_results)
want_keyboard :: #force_inline proc() -> bool {
    return state.active_input != nil
}