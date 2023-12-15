package main

import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

import "entity"
import "ngui"
import "level"

timescale: f32 = 1.0
lvl: level.Level
camera: rl.Camera2D

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

    camera = rl.Camera2D{ zoom = 1, offset = screen_size() / 2 }
    lvl := level.init({20, 15})
    defer level.deinit(lvl)
    camera.target = {
        lvl.grid.rect.x + lvl.grid.rect.width / 2,
        lvl.grid.rect.y + lvl.grid.rect.height / 2,
    }

    rl.SetTargetFPS(120)
    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime() * timescale

        mouse := rl.GetScreenToWorld2D(rl.GetMousePosition(), camera)
        level.update(&lvl, dt, mouse)

        rl.BeginDrawing()
        defer rl.EndDrawing()
        rl.ClearBackground(rl.WHITE)

        entity.draw(camera)
        rl.BeginMode2D(camera)
            level.draw(lvl)
        rl.EndMode2D()

        when ODIN_DEBUG {
            draw_gui(&lvl)
        }
    }
}

screen_size :: #force_inline proc() -> rl.Vector2 {
    return { f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight()) }
}

cam_follow :: proc(cam: ^rl.Camera2D, target: entity.Id, dt: f32) {
    ent := entity.get(target) or_else panic(#procedure + " requires a valid target")
    cam.target += (ent.pos - cam.target) * 0.9 * dt
}