package ngui

import rl "vendor:raylib"

state : NGui

NGui :: struct {
    parent: rl.Rectangle,
}

update :: proc() {
}

end :: proc() {
    state.parent = {}
}

panel :: proc(rect: rl.Rectangle, title: cstring) {
    title_rect := rect
    title_rect.height = TITLE_HEIGHT
    rl.DrawRectangleRec(title_rect, TITLE_COLOR)
    rl.DrawText(title, i32(title_rect.x + 5), i32(title_rect.y + 5), TITLE_FONT, rl.WHITE)

    body_rect := rect
    body_rect.height = rect.height - TITLE_HEIGHT
    body_rect.y = rect.y + TITLE_HEIGHT
    rl.DrawRectangleRec(body_rect, rl.RAYWHITE)

    state.parent = rect
}

slider :: proc(rect: rl.Rectangle, val: ^f32, $low, $high: f32, text: cstring) {
    #assert(low < high)
    pct := val^ / (high - low)

    mouse := rl.GetMousePosition()
    clicked := rl.IsMouseButtonPressed(.LEFT)

    slider_x := rect.x + pct * rect.width - SLIDER_WIDTH / 2 // Cursor should be in center of slider control
    slider_x  = clamp(slider_x, rect.x, rect.x + rect.width - SLIDER_WIDTH)
    slider_rect := rl.Rectangle{slider_x, rect.y, SLIDER_WIDTH, rect.height}


    hovered := rl.CheckCollisionPointRec(mouse, rect)
    if hovered && rl.IsMouseButtonDown(.LEFT) {
        mouse_pct := (mouse.x - rect.x) / rect.width
        val^ = mouse_pct * (high - low)
    }

    rl.DrawRectangleRec({rect.x, rect.y, rect.width, rect.height}, dark_color(hovered))
    rl.DrawRectangleRec(slider_rect, button_color(hovered))
    x := rect.x + rect.width + SLIDER_WIDTH / 2
    y := rect.y + rect.height / 2 - f32(FONT) / 2
    rl.DrawText(text, i32(x), i32(y), FONT, TEXT_COLOR)
}

button :: proc(rect: rl.Rectangle, label: cstring) -> bool {
    hovered := rl.CheckCollisionPointRec(rl.GetMousePosition(), rect)

    rl.DrawRectangleRec(rect, button_color(hovered))
    if label != nil {
        x := rect.x + (rect.width / 2) - f32(len(label)) * 2
        y := rect.y + (rect.height / 2) - (f32(FONT) / 2)
        rl.DrawText(label, i32(x), i32(y), FONT, rl.WHITE)
    }

    return hovered && rl.IsMouseButtonReleased(.LEFT)
}