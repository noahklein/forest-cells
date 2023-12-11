package ngui

import rl "vendor:raylib"
import "core:fmt"

state : NGui

NGui :: struct {
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

    if dragging != nil && rl.IsMouseButtonUp(.LEFT) {
        dragging = nil
    }

    if p, ok := &panels[dragging]; ok {
        pos := rl.GetMousePosition() + drag_offset
        p.rect.x = pos.x
        p.rect.y = pos.y
    }
}

slider :: proc(val: ^f32, $low, $high: f32) {
    #assert(low < high)
    pct := val^ / (high - low)

    panel, ok := &state.panels[state.panel]
    if !ok {
        panic("Slider must be placed in a panel")
    }
    rect := component_rect() or_else panic("Must be called between begin_panel() and end_panel()")

    slider_x := rect.x + pct * rect.width - SLIDER_WIDTH / 2 // Cursor should be in center of slider control
    slider_x  = clamp(slider_x, rect.x, rect.x + rect.width - SLIDER_WIDTH)
    slider_rect := rl.Rectangle{slider_x, rect.y, SLIDER_WIDTH, rect.height}

    key := fmt.ctprintf("%s#%.0fslider", state.panel, state.panel_row)
    mouse := rl.GetMousePosition()
    if rl.CheckCollisionPointRec(mouse, rect) && rl.IsMouseButtonPressed(.LEFT) {
        state.dragging = key
        state.drag_offset = {0, 0}
    }

    is_active := state.dragging == key
    if is_active {
        mouse_pct := (mouse.x - rect.x) / rect.width
        v := mouse_pct * (high - low)
        val^ = clamp(v, low, high)
    }

    rl.DrawRectangleRec({rect.x, rect.y, rect.width, rect.height}, dark_color(is_active))
    rl.DrawRectangleRec(slider_rect, button_color(is_active))

    x := rect.x + rect.width + SLIDER_WIDTH / 2
    y := rect.y + rect.height / 2 - f32(FONT) / 2
    rl.DrawText(fmt.ctprintf("%v", val^), i32(x), i32(y), FONT, TEXT_COLOR)
}

button :: proc(label: cstring) -> bool {
    rect := component_rect() or_else panic("Must be called between begin_panel() and end_panel()")

    hovered := rl.CheckCollisionPointRec(rl.GetMousePosition(), rect)

    rl.DrawRectangleRec(rect, button_color(hovered))
    if label != nil {
        x := rect.x + (rect.width / 2) - f32(len(label)) * 2
        y := rect.y + (rect.height / 2) - (f32(FONT) / 2)
        rl.DrawText(label, i32(x), i32(y), FONT, rl.WHITE)
    }

    return hovered && rl.IsMouseButtonReleased(.LEFT)
}