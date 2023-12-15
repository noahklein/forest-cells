package main

import rl "vendor:raylib"
import "ngui"
import "player"
import "entity"

str: string

draw_gui :: proc() {
    ngui.update()

    if ngui.begin_panel("Game", {1290, 20, 300, 0}) {
        if ngui.flex_row({0.7, 0.2}) {
            ngui.slider(&timescale, 0, 10)
            ngui.text("%.1fx Speed", timescale)
        }

        MAX_SPEED :: 200
        ent := entity.get(player.player.ent_id) or_else panic("Missing player entity in gui")
        if ngui.flex_row({0.2, 0.4, 0.4}) {
            ngui.text("Player")
            ngui.vec2(&ent.pos, label = "Pos")
            ngui.vec2(&player.player.vel, min = -MAX_SPEED, max = MAX_SPEED, step = 0.1, label = "Vel")
        }

        if ngui.flex_row({0.2, 0.4, 0.4}) {
            ngui.text("Camera")
            ngui.vec2(&camera.offset, label = "Offset")
            ngui.float(&camera.zoom, min = 0, max = 10, label = "Zoom")
        }

        if ngui.flex_row({1}) {
            ngui.input(&str, "Input")
        }
    }

    rl.DrawFPS(rl.GetScreenWidth() - 80, 0)
}