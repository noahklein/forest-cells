package level

import "core:fmt"
import rl "vendor:raylib"
import "../grid"
// import "../entity"
// import "../render"

FIXED_DT :: 1 // seconds

Level :: struct {
    data: []union{int, f32},

    _grid: grid.Grid,
    dt_acc: f32,
}

init :: proc(size: rl.Vector2) -> Level {
    return { _grid = grid.init(size) }
}

update :: proc(using level: ^Level, dt: f32) {
    // @HACK
    _grid = grid.init(_grid.size)

    level.dt_acc += dt
    for level.dt_acc >= FIXED_DT {
        tick(level, FIXED_DT)
        level.dt_acc -= FIXED_DT
    }

    handle_mouse(level)
}

tick :: proc(using level: ^Level, dt: f32) {
}

handle_mouse :: proc(using level: ^Level) -> bool {
    cell := grid.hovered_cell(_grid) or_return

    mod: rl.Color = {10, 10, 0, 0} if rl.IsMouseButtonDown(.LEFT) else 0
    rl.DrawRectangleV(cell, grid.CELL_SIZE, rl.YELLOW - mod)

    if rl.IsMouseButtonPressed(.LEFT) {
        ints := grid.vec_to_int(_grid, cell)
        fmt.println(ints)
    }

    return true
}

draw :: proc(using level: Level) {
    grid.draw(_grid)
}