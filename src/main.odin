package main

import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

import "entity"
import "render"

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

    NUM_ENTITIES :: 128 // Just a projection to pre-allocate.
    entity.init(NUM_ENTITIES)
    defer entity.deinit()
    render.init(NUM_ENTITIES)
    defer render.deinit()

    id := entity.create({ pos = {0, 0}, scale = 50 })
    render.add(.FG, { id, .Circle, rl.RED })

    camera := rl.Camera2D{ zoom = 1, offset = screen_size() / 2 }

    rl.SetTargetFPS(120)
    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        render.draw(camera)
    }
}

screen_size :: #force_inline proc() -> rl.Vector2 {
    return { f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight()) }
}