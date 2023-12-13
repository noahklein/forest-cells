package grid

import rl "vendor:raylib"

Grid :: struct {
    size: rl.Vector2,
    rect: rl.Rectangle,
}

CELL_SIZE :: 50

init :: proc(size: rl.Vector2) -> Grid {
    s_width, s_height := f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())

    g_width, g_height := size.x * CELL_SIZE, size.y * CELL_SIZE
    return {
        size = size,
        rect = {
            s_width  / 2 - g_width  / 2,
            s_height / 2 - g_height / 2,
            g_width,
            g_height,
        },
    }
}

hovered_cell :: proc(using grid: Grid) -> (rl.Vector2, bool) {
    mouse := rl.GetMousePosition()
    if !rl.CheckCollisionPointRec(mouse, rect) {
        return 0, false
    }

    // top_left := snap_down_mouse(mouse)
    // Snap down to top-left corner of hovered cell.
    origin := rl.Vector2{rect.x, rect.y}
    return snap_down_mouse(mouse - origin) + origin, true
}

draw :: proc(using grid: Grid) {
    // Vertical lines.
    for x in 0..=size.x {
        column := rect.x + f32(x * CELL_SIZE)
        rl.DrawLineV({column, rect.y}, {column, rect.y + rect.height}, rl.BLACK)
    }
    // Horizontal lines.
    for y in 0..=size.y {
        row := rect.y + f32(y * CELL_SIZE)
        rl.DrawLineV({rect.x, row}, {rect.x + rect.width, row}, rl.BLACK)
    }
}

@(require_results)
snap_down :: #force_inline proc(i: i32) -> i32 {
    if i < 0 {
        return ((i - CELL_SIZE + 1) / CELL_SIZE) * CELL_SIZE
    }

    return (i / CELL_SIZE) * CELL_SIZE
}

@(require_results)
snap_up :: #force_inline proc(i: i32) -> i32 {
    if i < 0 {
        return (i / CELL_SIZE) * CELL_SIZE
    }

    return ((i + CELL_SIZE - 1) / CELL_SIZE) * CELL_SIZE
}

@(require_results)
snap_down_mouse :: #force_inline proc(m: rl.Vector2) -> rl.Vector2 {
    return { f32(snap_down(i32(m.x))), f32(snap_down(i32(m.y))) }
}

@(require_results)
snap_up_mouse :: #force_inline proc(m: rl.Vector2) -> rl.Vector2 {
    return { f32(snap_up(i32(m.x))), f32(snap_up(i32(m.y))) }
}
