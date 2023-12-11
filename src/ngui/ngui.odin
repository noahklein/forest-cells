package ngui

import "core:math/linalg"
import "core:fmt"
import rl "vendor:raylib"

INF :: f32(1e7)

state : NGui

NGui :: struct {
    mouse: rl.Vector2, // Mouse position

    dragging: cstring,
    drag_offset: rl.Vector2,

    panels: map[cstring]Panel,
    panel: cstring, // Active panel
    panel_row, panel_column: int,
    column_widths: []f32,
}

TextAlign :: enum {
    Left,
    Center,
}

init :: proc() {
}

deinit :: proc() {
    delete(state.panels)
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
    if pressed(rect) {
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

    rl.DrawRectangleRec(rect, button_color(hovered(rect), dragging))
    label_rect(rect, fmt.ctprintf("%.2f", f^), color = rl.WHITE, align = .Center)
}

labelf :: proc($format: string, args: ..any, color := TEXT_COLOR, align := TextAlign.Left) {
    rect := flex_rect() or_else panic("Must be called between begin_panel() and end_panel()")

    text := fmt.ctprintf(format, ..args)
    label_rect(rect, text, color)
}

label_rect :: proc(rect: rl.Rectangle, text: cstring, color := TEXT_COLOR, align := TextAlign.Left) {
    y := rect.y + (rect.height / 2) - (f32(FONT) / 2)

    x := rect.x
    if align == .Center {
        x = rect.x + (rect.width / 2) - f32(len(text)) * 2
    }

    rl.DrawText(text, i32(x), i32(y), FONT, color)
}

@(require_results)
pressed :: #force_inline proc(rect: rl.Rectangle) -> bool {
    return rl.IsMouseButtonPressed(.LEFT) && hovered(rect)
}

@(require_results)
hovered :: #force_inline proc(rect: rl.Rectangle) -> bool {
    return rl.CheckCollisionPointRec(state.mouse, rect)
}