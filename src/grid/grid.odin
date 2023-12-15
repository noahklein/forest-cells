package grid

import "core:math/linalg"
import rl "vendor:raylib"
import "../entity"

Grid :: struct {
    size: rl.Vector2,
    rect: rl.Rectangle,
}

CELL_SIZE :: 50

init :: proc(pos, size: rl.Vector2) -> Grid {
    g_width, g_height := size.x * CELL_SIZE, size.y * CELL_SIZE

    // Vertical lines.
    for x in 0..=size.x {
        column := pos.x + f32(x * CELL_SIZE)
        line := entity.Line{ end = { column, pos.y + g_height }}
        entity.create({
            pos = {column, pos.y},
            graphic = { .UI, rl.BLACK, line },
        })
    }

    // Horizontal lines.
    for y in 0..=size.y {
        row := pos.y + f32(y * CELL_SIZE)
        line := entity.Line{ end = { pos.x + g_width, row }}
        entity.create({
            pos = {pos.x, row},
            graphic = { .UI, rl.BLACK, line },
        })
    }

    return {
        size = size,
        rect = { pos.x, pos.y, g_width, g_height },
    }
}

hovered_cell :: proc(using grid: Grid, mouse: rl.Vector2) -> (rl.Vector2, bool) {
    // Exclude outer grid borders from collision.
    collide := (rect.x < mouse.x && mouse.x < rect.x + rect.width) &&
               (rect.y < mouse.y && mouse.y < rect.y + rect.height)
    if  !collide {
        return 0, false
    }

    // Snap down to top-left corner of hovered cell.
    origin := rl.Vector2{rect.x, rect.y}
    return snap_down(mouse - origin) + origin, true
}

@(require_results)
vec_to_ivec :: #force_inline proc(g: Grid, v: rl.Vector2) -> [2]int {
    origin := rl.Vector2{g.rect.x, g.rect.y}
    return linalg.array_cast((v - origin) / CELL_SIZE, int)
}

@(require_results)
vec_to_int :: #force_inline proc(g: Grid, v: rl.Vector2) -> int {
    ivec := vec_to_ivec(g, v)
    return ivec_to_int(g, ivec)
}

@(require_results)
ivec_to_int :: #force_inline proc(g: Grid, ivec: [2]int) -> int {
    return ivec.x + ivec.y * int(g.size.x)
}

@(require_results)
int_to_ivec :: #force_inline proc(g: Grid, i: int) -> [2]int {
    width := int(g.size.x)
    return {i % width, i / width }
}

@(require_results)
int_to_vec :: #force_inline proc(g: Grid, i: int) -> rl.Vector2 {
    ivec := int_to_ivec(g, i)
    v := rl.Vector2(linalg.array_cast(ivec, f32))

    origin := rl.Vector2{g.rect.x, g.rect.y}
    return (v + origin) * CELL_SIZE
}

in_bounds :: #force_inline proc(g: Grid, ivec: [2]int) -> bool {
    return 0 <= ivec.x && ivec.x < int(g.size.x) &&
           0 <= ivec.y && ivec.y < int(g.size.y)
}

snap_down :: proc{
    snap_down_i32,
    snap_down_vec,
}

@(require_results)
snap_down_i32 :: #force_inline proc(i: i32) -> i32 {
    if i < 0 {
        return ((i - CELL_SIZE + 1) / CELL_SIZE) * CELL_SIZE
    }

    return (i / CELL_SIZE) * CELL_SIZE
}

@(require_results)
snap_down_vec :: #force_inline proc(m: rl.Vector2) -> rl.Vector2 {
    return { f32(snap_down(i32(m.x))), f32(snap_down(i32(m.y))) }
}

snap_up :: proc{
    snap_up_i32,
    snap_up_vec,
}

@(require_results)
snap_up_i32 :: #force_inline proc(i: i32) -> i32 {
    return snap_down(i) + CELL_SIZE
}

@(require_results)
snap_up_vec :: #force_inline proc(m: rl.Vector2) -> rl.Vector2 {
    return { f32(snap_up(i32(m.x))), f32(snap_up(i32(m.y))) }
}