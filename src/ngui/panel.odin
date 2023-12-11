package ngui

import "core:fmt"
import rl "vendor:raylib"

Panel :: struct {
    rect: rl.Rectangle,
}

begin_panel :: proc($title: cstring, rect: rl.Rectangle) {
    fmt.assertf(state.panel == nil || state.panel == title, "already building panel %q; did you forget an end()?", title)
    if title not_in state.panels {
        state.panels[title] = { rect = rect }
    }
    state.panel = title
    state.panel_row = 0
    rect := state.panels[title].rect

    mouse := rl.GetMousePosition()

    title_rect := rect
    title_rect.height = TITLE_HEIGHT

    if rl.IsMouseButtonPressed(.LEFT) && rl.CheckCollisionPointRec(mouse, title_rect) {
        state.dragging = title
        state.drag_offset = rl.Vector2{title_rect.x, title_rect.y} - mouse
    }

    rl.DrawRectangleRec(title_rect, title_color(state.dragging == title))
    rl.DrawText(title, i32(title_rect.x + 5), i32(title_rect.y + 5), TITLE_FONT, rl.WHITE)

    body_rect := rect
    body_rect.height = rect.height - TITLE_HEIGHT
    body_rect.y = rect.y + TITLE_HEIGHT
    rl.DrawRectangleRec(body_rect, rl.LIGHTGRAY)
}

end_panel :: proc() {
    state.panel = nil
}

COMPONENT_HEIGHT :: TITLE_HEIGHT - 2
COMPONENT_PADDING :: rl.Vector2{10, 5}
component_rect :: proc(p: ^Panel) -> rl.Rectangle {
    defer state.panel_row += 1
    return {
        p.rect.x + COMPONENT_PADDING.x,
        p.rect.y + TITLE_HEIGHT + state.panel_row * COMPONENT_HEIGHT + COMPONENT_PADDING.y,
        p.rect.width - COMPONENT_PADDING.x,
        COMPONENT_HEIGHT - COMPONENT_PADDING.y,
    }
}