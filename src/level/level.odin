package level

import rl "vendor:raylib"
import "../grid"
import "../entity"
import "core:fmt"

FIXED_DT :: 1 // seconds

Level :: struct {
    data: [dynamic]Tile,
    animals: [dynamic]Animal,
    grid: grid.Grid,
    hovered: rl.Vector2,
    dt_acc: f32,

    brush: TileType,
    stats: struct {
        live, dead, ticks: int,
    },
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
    delete(level.animals)
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
    level.stats.ticks += 1

    NEIGHBORS :: [4][2]int {
        {-1,  0}, {1, 0},
        { 0, -1}, {0, 1},
    }

    for &tile in level.data {
        tile.modified = false
    }

    for &tile, i in level.data {
        defer tile.time_in_state += 1

        if tile.modified {
            continue
        }

        switch tile.type {
        case .Water:
            ivec := grid.int_to_ivec(level.grid, i)
            for nbr in NEIGHBORS {
                target := ivec + nbr
                if !grid.in_bounds(level.grid, target) do continue

                nbr_i := grid.ivec_to_int(level.grid, target)
                nbr_tile := &level.data[nbr_i]

                switch nbr_tile.type {
                    case .Empty:       set_tile_type(nbr_tile, .Water)
                    case .Dirt:        if nbr_tile.time_in_state > 3 do set_tile_type(nbr_tile, .FertileDirt)
                    case .Grass, .FertileDirt, .Water, .Poop: continue
                }
            }
        case .FertileDirt:
            ivec := grid.int_to_ivec(level.grid, i)
            for nbr in NEIGHBORS {
                target := ivec + nbr
                if !grid.in_bounds(level.grid, target) do continue
                nbr_i := grid.ivec_to_int(level.grid, target)
                nbr_tile := &level.data[nbr_i]
                if nbr_tile.type == .Grass {
                    set_tile_type(&tile, .Grass)
                }
            }
        case .Poop:
            if tile.time_in_state > 3 {
                set_tile_type(&tile, .FertileDirt)
            }
        case .Empty, .Dirt, .Grass:
        }
    }

    // Animals
    for &animal, i in level.animals {
        ent := entity.get(animal.ent_id) or_else panic("Animal entity missing")

        if animal.health < 0 {
            animal.health = 0
        }
        if animal.health == 0 {
            animal.state = Dead{}
            ent.graphic.tint = rl.PURPLE
        }
        if animal.health >= 20 {
            animal.health = 10
            animal_spawn(level, animal.type)
        }


        switch &state in animal.state {
        case Dead:
            level.stats.dead += 1
            level.stats.live -= 1
            entity.destroy(animal.ent_id)
            unordered_remove(&level.animals, i)
            continue
        case FindFood:
            target, ok := find_tile(level, ANIMAL_FOOD[animal.type])
            if !ok {
                fmt.println("Ouch. No tiles available of type", ANIMAL_FOOD[animal.type])
                animal.health -= 1
                continue
            }

            level.data[target].occupied = true
            animal.state = Move{ target, 1 }

        case Move:
            // @TODO: interpolate.
            fmt.println("moving to", grid.int_to_ivec(level.grid, state.target))
            ent.pos = grid.int_to_vec(level.grid, state.target)

            state.duration -= dt
            if state.duration <= 0 {
                animal.state = Eat{state.target}
            }

        case Eat:
            ent.pos = grid.int_to_vec(level.grid, state.target)
            set_tile_type(&level.data[state.target], .Poop)
            level.data[state.target].occupied = false

            animal.health += 1
            animal.state = FindFood{}
        }
    }
}

find_tile :: proc(level: ^Level, type: TileType) -> (int, bool) {
    for tile, i in level.data {
        if !tile.modified && !tile.occupied && tile.type == type {
            return i, true
        }
    }

    return -1, false
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
    tile.time_in_state = 0
    ent := entity.get(tile.ent_id) or_else panic(#procedure + "() missing entity", loc)
    ent.graphic.tint = TILE_COLORS[type]
}