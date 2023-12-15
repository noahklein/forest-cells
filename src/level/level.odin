package level

import rl "vendor:raylib"
import "../grid"
import "../entity"

FIXED_DT :: 1 // seconds

Level :: struct {
    data: [dynamic]Tile,
    grid: grid.Grid,
    hovered: rl.Vector2,
    dt_acc: f32,

    brush: TileType,
}

init :: proc(size: rl.Vector2) -> (lvl: Level) {
    lvl.grid = grid.init(0, size)
    lvl.data = make([dynamic]Tile, int(size.x * size.y))
    for &tile, i in lvl.data {
        tile.ent_id = entity.create({
            pos = grid.int_to_vec(lvl.grid, i),
            graphic = {.BG, TILE_COLORS[.Empty], entity.Rect{grid.CELL_SIZE}},
        })
    }

    lvl.hovered = -1
    return
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

tick :: proc(level: ^Level, dt: f32) {
    NEIGHBORS :: [4][2]int {
        {-1,  0}, {1, 0},
        { 0, -1}, {0, 1},
    }

    for &tile in level.data {
        tile.modified = false
    }

    for tile, i in level.data {
        if tile.modified {
            continue
        }

        switch tile.type {
            case .Water: // @TODO: fill empty neighbors, fertilize dirt neighbors
                ivec := grid.int_to_ivec(level.grid, i)
                for nbr in NEIGHBORS {
                    target := ivec + nbr
                    if !grid.in_bounds(level.grid, target) do continue

                    nbr_i := grid.ivec_to_int(level.grid, target)
                    nbr_tile := &level.data[nbr_i]

                    switch nbr_tile.type {
                        case .Empty:
                            set_tile_type(nbr_tile, .Water)
                        case .Water:
                        case .Dirt:
                            set_tile_type(nbr_tile, .FertileDirt)
                        case .FertileDirt:
                            set_tile_type(nbr_tile, .Grass)
                        case .Grass:
                    }

                }

            case .Empty, .Dirt, .FertileDirt, .Grass:
        }
    }
}

handle_mouse :: proc(level: ^Level, mouse: rl.Vector2) -> bool {
    cell, is_hover := grid.hovered_cell(level.grid, mouse)
    if !is_hover {
        level.hovered = -1
        return false
    }
    level.hovered = cell

    if rl.IsMouseButtonPressed(.LEFT) {
        i := grid.vec_to_int(level.grid, cell)
        set_tile_type(&level.data[i], level.brush)
    }

    return true
}

draw :: proc(level: Level) {
    if level.hovered != -1 {
        green := rl.Color{0, 255, 0, 60}
        rl.DrawRectangleV(level.hovered, grid.CELL_SIZE, green)
    }
}

set_tile_type :: proc(tile: ^Tile, type: TileType, loc:=#caller_location) {
    tile.type = type
    tile.modified = true
    ent := entity.get(tile.ent_id) or_else panic(#procedure + "() missing entity", loc)
    ent.graphic.tint = TILE_COLORS[type]
}