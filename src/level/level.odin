package level

import "core:fmt"
import rl "vendor:raylib"
import "../grid"
import "../entity"
import "../render"

FIXED_DT :: 1 // seconds

Level :: struct {
    data: [dynamic]Tile,
    grid: grid.Grid,
    hovered: rl.Vector2,
    dt_acc: f32,
}

init :: proc(size: rl.Vector2) -> Level {
    return {
        data = make([dynamic]Tile, int(size.x * size.y)),
        grid = grid.init(0, size),
        hovered = -1,
    }
}

deinit :: proc(level: Level) {
    delete(level.data)
}

update :: proc(level: ^Level, dt: f32, mouse: rl.Vector2) {
    level.dt_acc += dt
    for level.dt_acc >= FIXED_DT {
        tick(level, FIXED_DT)
        level.dt_acc -= FIXED_DT
    }

    handle_mouse(level, mouse)
}

tick :: proc(level: ^Level, dt: f32) {}

handle_mouse :: proc(level: ^Level, mouse: rl.Vector2) -> bool {
    cell, is_hover := grid.hovered_cell(level.grid, mouse)
    if !is_hover {
        level.hovered = -1
        return false
    }
    level.hovered = cell

    if rl.IsMouseButtonPressed(.LEFT) {
        i := grid.vec_to_int(level.grid, cell)
        if level.data[i].ent_id == {0, 0} {
            fmt.println("fresh", i, grid.vec_to_ivec(level.grid, cell))
            id := entity.create(entity.Entity{ pos = cell })
            level.data[i] = Tile{ ent_id = id, type = Dirt{} }
            render.add(.FG, render.Graphic{id, rl.ORANGE, render.Rect{size = grid.CELL_SIZE} })
        }
    }

    return true
}

draw :: proc(level: Level) {
    if level.hovered != -1 {
        green := rl.Color{0, 255, 0, 50}
        rl.DrawRectangleV(level.hovered, grid.CELL_SIZE, green)
    }
}