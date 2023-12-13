package main

import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

import "entity"
import "player"
import "render"
import "ngui"
import "grid"

timescale: f32 = 1.0
level_grid: grid.Grid

main :: proc() {
     when ODIN_DEBUG {
        track: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track, context.allocator)
        context.allocator = mem.tracking_allocator(&track)

        defer {
            if len(track.allocation_map) > 0 {
                fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
                for _, entry in track.allocation_map {
                    fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
                }
            }
            if len(track.bad_free_array) > 0 {
                fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
                for entry in track.bad_free_array {
                    fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
                }
            }
            mem.tracking_allocator_destroy(&track)
        }
    }
    defer free_all(context.temp_allocator)

    rl.SetTraceLogLevel(.ALL if ODIN_DEBUG else .WARNING)
    rl.InitWindow(1600, 900, "Terminalia")
    defer rl.CloseWindow()

    ngui.init()
    defer ngui.deinit()

    NUM_ENTITIES :: 128 // Just a projection to pre-allocate.
    entity.init(NUM_ENTITIES)
    defer entity.deinit()
    render.init(NUM_ENTITIES)
    defer render.deinit()

    // Player entity
    id := entity.create({ pos = {0, 0}, scale = 50 })
    player.player.ent_id = id
    // render.add(.FG, { id, .Circle, rl.RED })

    camera := rl.Camera2D{ zoom = 1, offset = screen_size() / 2 }
    level_grid = grid.init({5, 4})

    rl.SetTargetFPS(120)
    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime() * timescale

        player_input := player.get_input()
        player.update(player_input, dt)
        render.draw(camera)

        level_grid = grid.init(level_grid.size)
        if x, ok := grid.hovered_cell(level_grid); ok {
            rl.DrawRectangleV(x, {grid.CELL_SIZE, grid.CELL_SIZE}, rl.YELLOW)
        }

        grid.draw(level_grid)


        when ODIN_DEBUG {
            draw_gui()
        }
    }
}

screen_size :: #force_inline proc() -> rl.Vector2 {
    return { f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight()) }
}