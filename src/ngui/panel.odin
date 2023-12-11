package ngui

import "core:fmt"
import rl "vendor:raylib"

Panel :: struct {
    rect: rl.Rectangle,
    minimized: bool,
}

begin_panel :: proc($title: cstring, rect: rl.Rectangle) {
    fmt.assertf(state.panel == nil || state.panel == title, "already building panel %q; did you forget an end()?", title)
    if title not_in state.panels {
        state.panels[title] = { rect = rect }
    }
    state.panel = title
    state.panel_row = 0

    panel := &state.panels[title]
    rect := state.panels[title].rect


    title_rect := rect
    title_rect.height = TITLE_HEIGHT

    minimize_button_rect := rl.Rectangle{
        title_rect.x + title_rect.width - TITLE_HEIGHT, title_rect.y,
        TITLE_HEIGHT, TITLE_HEIGHT,
    }
    hover_minimize := rl.CheckCollisionPointRec(state.mouse, minimize_button_rect)
    if !hover_minimize && rl.IsMouseButtonPressed(.LEFT) && rl.CheckCollisionPointRec(state.mouse, title_rect) {
        state.dragging = title
        state.drag_offset = rl.Vector2{title_rect.x, title_rect.y} - state.mouse
    }

    rl.DrawRectangleRec(title_rect, title_color(state.dragging == title))
    rl.DrawText(title, i32(title_rect.x + 5), i32(title_rect.y + 5), TITLE_FONT, rl.WHITE)
    if button_rect(minimize_button_rect, "+" if panel.minimized else "-") {
        panel.minimized = !panel.minimized
    }

    if panel.minimized {
        return
    }

    body_rect := rect
    body_rect.height = rect.height - TITLE_HEIGHT
    body_rect.y = rect.y + TITLE_HEIGHT
    rl.DrawRectangleRec(body_rect, rl.LIGHTGRAY)
}

end_panel :: proc() {
    body_height := state.panel_row * COMPONENT_HEIGHT
    p := &state.panels[state.panel] or_else panic("end_panel() called on a missing panel")
    if body_height > p.rect.height - TITLE_HEIGHT {
        p.rect.height = body_height + 2 * TITLE_HEIGHT
    }

    state.panel = nil
}

COMPONENT_HEIGHT  :: TITLE_HEIGHT - 2
COMPONENT_PADDING :: rl.Vector2{20, 5}

component_rect :: proc() -> (rect: rl.Rectangle, visible, ok: bool) {
    p, p_ok := &state.panels[state.panel]
    if !p_ok {
        return {}, false, false
    }

    if p.minimized {
        return {}, false, true
    }
    defer state.panel_row += 1

    return {
        p.rect.x + COMPONENT_PADDING.x,
        p.rect.y + TITLE_HEIGHT + state.panel_row * COMPONENT_HEIGHT + COMPONENT_PADDING.y,
        p.rect.width - 2 * COMPONENT_PADDING.x,
        COMPONENT_HEIGHT - COMPONENT_PADDING.y,
    }, true, true
}