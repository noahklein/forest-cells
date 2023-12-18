package main

import "core:fmt"
import rl "vendor:raylib"
import "ngui"
import "level"
// import "entity"

draw_gui :: proc(lvl: ^level.Level) {
    ngui.update()

    if ngui.begin_panel("Game", {0, 0, 400, 0}) {
        if ngui.flex_row({0.6, 0.2, 0.2}) {
            ngui.slider(&timescale, 0, 10)
            ngui.text("%.1fx Speed", timescale)
            ngui.text("Ticks: %v", lvl.ticks, align = .Right)
        }

        if ngui.flex_row({0.33, 0.33, 0.33}) {
            paused := timescale == 0
            if ngui.button("Play" if paused else "Pause") || rl.IsKeyPressed(.SPACE) {
                timescale = 1 if paused else 0
            }

            if ngui.button("Tick") || rl.IsKeyPressed(.TAB) {
                timescale = 0
                level.tick(lvl, level.FIXED_DT)
            }
        }

        if ngui.flex_row({0.2, 0.3, 0.3, 0.2}) {
            ngui.text("Camera")
            ngui.vec2(&camera.offset, label = "Offset")
            ngui.vec2(&camera.target, label = "Target")
            ngui.float(&camera.zoom, min = 0, max = 10, label = "Zoom")
        }
    }

    if ngui.begin_panel("Level", {1196, 22, 400, 91}) {
        if ngui.flex_row({1}) {
            ngui.radio_group(level.TileType, &lvl.brush, "Brush")
        }
        if ngui.flex_row({1}) {
            if ngui.button("Clear") {
                for &tile in lvl.data {
                    level.set_tile_type(&tile, .Empty)
                }
            }
        }

        columns : [len(level.AnimalType)]f32
        for _, i in level.AnimalType do columns[i] = 1.0 / len(level.AnimalType)
        if ngui.flex_row(columns[:]) {
            for type in level.AnimalType {
                if ngui.button(fmt.ctprintf("%v", type)) {
                    level.animal_spawn(lvl, type)
                }
            }
        }
    }

    if ngui.begin_panel("Animals", {0, 400, 300, 0}) {
        for animal in lvl.animals {
            if ngui.flex_row({0.2, 0.2, 0.6}) {
                ngui.text("%v", animal.type)
                ngui.text("Health %v", animal.health)
                ngui.text("State %v", animal.state)
            }
        }
    }

    rl.DrawFPS(rl.GetScreenWidth() - 80, 0)
}