package ngui

import "core:math/linalg"
import "core:fmt"
import rl "vendor:raylib"

INF :: 1e7

state : NGui

NGui :: struct {
    mouse: rl.Vector2, // Mouse position

    dragging: cstring,
    drag_offset: rl.Vector2,

    panels: map[cstring]Panel,
    panel: cstring, // Active panel
    panel_row: f32,
}

init :: proc() {
}

deinit :: proc() {
    delete(state.panels)
}

update :: proc() {
    using state;

    mouse = rl.GetMousePosition()

    if dragging != nil && rl.IsMouseButtonUp(.LEFT) {
        dragging = nil
    }

    if p, ok := &panels[dragging]; ok {
        pos := mouse + drag_offset
        p.rect.x = pos.x
        p.rect.y = pos.y
    }

}

slider_rect :: proc(rect: rl.Rectangle, val: ^f32, $low, $high: f32) {
    #assert(low < high)
    pct := val^ / (high - low)

    slider_x := rect.x + pct * rect.width - SLIDER_WIDTH / 2 // Cursor should be in center of slider control
    slider_x  = clamp(slider_x, rect.x, rect.x + rect.width - SLIDER_WIDTH)
    slider_rect := rl.Rectangle{slider_x, rect.y, SLIDER_WIDTH, rect.height}

    key := fmt.ctprintf("%s#%.0fslider", state.panel, state.panel_row)
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

    rl.DrawRectangleRec({rect.x, rect.y, rect.width, rect.height}, dark_color(is_active))
    rl.DrawRectangleRec(slider_rect, button_color(is_active))

    x := rect.x + rect.width + SLIDER_WIDTH / 2
    y := rect.y + rect.height / 2 - f32(FONT) / 2
    rl.DrawText(fmt.ctprintf("%v", val^), i32(x), i32(y), FONT, TEXT_COLOR)
}

slider :: proc(val: ^f32, $low, $high: f32) {
    panel, ok := &state.panels[state.panel]
    if !ok {
        panic("Slider must be placed in a panel")
    }
    rect := component_rect() or_else panic("Must be called between begin_panel() and end_panel()")

    slider_rect(rect, val, low, high)
}

button :: proc(label: cstring) -> bool {
    rect := component_rect() or_else panic("Must be called between begin_panel() and end_panel()")
    return button_rect(rect, label)
}

button_rect :: proc(rect: rl.Rectangle, label: cstring) -> bool {
    hovered := rl.CheckCollisionPointRec(rl.GetMousePosition(), rect)

    rl.DrawRectangleRec(rect, button_color(hovered))
    if label != nil {
        center_text(rect, label, rl.WHITE)
    }

    return hovered && rl.IsMouseButtonReleased(.LEFT)
}


vec2 :: proc(v: ^rl.Vector2, min: f32 = -INF, max: f32 = INF, step: f32 = 0.1) {
    rect := component_rect() or_else panic("Must be called between begin_panel() and end_panel()")
    rect.width /= 2

    first := rect
    f32_rect(first, &v.x, min, max, step)

    second := rect
    second.x += rect.width
    f32_rect(second, &v.y, min, max, step)
}

// Draggable f32 editor. Hold alt while dragging for finer control, hold shift to speed it up.
f32_rect :: proc(rect: rl.Rectangle, f: ^f32, min: f32 = -INF, max: f32 = INF, step: f32 = 0.1) {
    key := fmt.ctprintf("f32#%v", rect)
    if pressed(rect) {
        state.dragging = key
        state.drag_offset = rl.Vector2{rect.x, rect.y} - state.mouse
    }
    dragging := state.dragging == key
    if dragging {
        slow_down: f32 = 0.1 if rl.IsKeyDown(.LEFT_ALT)   else 1.0
        speed_up : f32 = 10  if rl.IsKeyDown(.LEFT_SHIFT) else 1.0
        f^ += rl.GetMouseDelta().x * step * slow_down
        f^ = clamp(f^, min, max)
    }

    rl.DrawRectangleRec(rect, button_color(dragging))
    center_text(rect, fmt.ctprintf("%.2f", f^), rl.WHITE)
}

center_text :: proc(rect: rl.Rectangle, text: cstring, color: rl.Color = TEXT_COLOR) {
    x := rect.x + (rect.width / 2) - f32(len(text)) * 2
    y := rect.y + (rect.height / 2) - (f32(FONT) / 2)
    rl.DrawText(text, i32(x), i32(y), FONT, color)
}

pressed :: #force_inline proc(rect: rl.Rectangle) -> bool {
    return rl.IsMouseButtonPressed(.LEFT) && rl.CheckCollisionPointRec(rl.GetMousePosition(), rect)
}