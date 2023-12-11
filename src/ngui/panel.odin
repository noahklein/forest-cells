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


    // Title bar.
    title_rect := rect
    title_rect.height = TITLE_HEIGHT

    // Minimize button.
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

    // Panel Body. Note: height is resized to fit contents every frame.
    body_rect := rect
    body_rect.height = rect.height - TITLE_HEIGHT
    body_rect.y = rect.y + TITLE_HEIGHT
    rl.DrawRectangleRec(body_rect, rl.LIGHTGRAY)

    {
        // Resize window.
        using body_rect
        SIZE :: 10
        // Resize triangle drawn in bottom right corner.
        a, b, c: rl.Vector2
        a = {x + width, y + height}
        b = a - {0, SIZE}
        c = a - {SIZE, 0}

        // Circle around the bottom-right corner for mouse collision. The actual resize
        // triangle is way too small to click.
        hovered := rl.CheckCollisionPointCircle(state.mouse, a, SIZE * 1.5)

        resize_key := fmt.ctprintf("%s#resize", title)
        if hovered && rl.IsMouseButtonPressed(.LEFT) {
            state.dragging = resize_key
            state.drag_offset = a - state.mouse
        }

        if state.dragging == resize_key {
            mouse := state.mouse + state.drag_offset
            panel.rect.width  = mouse.x - panel.rect.x
            panel.rect.height = mouse.y - panel.rect.y
            panel.rect.width  = clamp(panel.rect.width,  150, f32(rl.GetScreenWidth()))
            panel.rect.height = clamp(panel.rect.height,  50, f32(rl.GetScreenHeight()))
        }

        rl.DrawTriangle(a, b, c, title_color(hovered))
    }
}

end_panel :: proc() {
    body_height := f32(state.panel_row) * COMPONENT_HEIGHT
    p := &state.panels[state.panel] or_else panic("end_panel() called on a missing panel")
    if body_height > p.rect.height - TITLE_HEIGHT {
        p.rect.height = body_height + 2 * TITLE_HEIGHT
    }

    state.panel = nil
    state.panel_row = 0
}

begin_row :: proc(column_widths: []f32) {
    state.column_widths = column_widths
    state.panel_column = 0
}

end_row :: proc() {
    state.panel_row += 1
}

COMPONENT_HEIGHT  :: TITLE_HEIGHT - 2
COMPONENT_PADDING :: rl.Vector2{5, 5}

flex_rect :: proc() -> (rect: rl.Rectangle, visible, ok: bool) {
    p, p_ok := &state.panels[state.panel]
    if !p_ok {
        return {}, false, false
    }

    if p.minimized {
        return {}, false, true
    }
    defer state.panel_column += 1

    row_rect := rl.Rectangle{
        p.rect.x + COMPONENT_PADDING.x,
        p.rect.y + TITLE_HEIGHT + f32(state.panel_row) * COMPONENT_HEIGHT + COMPONENT_PADDING.y,
        p.rect.width - COMPONENT_PADDING.x,
        COMPONENT_HEIGHT - COMPONENT_PADDING.y,
    }

    fmt.assertf(state.panel_column < len(state.column_widths), "Too many components in row. Must be 1:1 with row's column widths: Panel = %s, row = %v", state.panel, state.panel_row)

    rect = row_rect
    rect.width = row_rect.width * state.column_widths[state.panel_column] - COMPONENT_PADDING.x
    for pct in state.column_widths[:state.panel_column] {
        rect.x += pct * row_rect.width // - COMPONENT_PADDING.x
    }

    return rect, true, true

}