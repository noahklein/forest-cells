package main

import rl "vendor:raylib"
import "ngui"
import "player"
import "entity"

draw_gui :: proc() {
    ngui.update()

    if ngui.begin_panel("Game", {1290, 20, 300, 0}) {
        if ngui.flex_row({0.7, 0.2}) {
            ngui.slider(&timescale, 0, 10)
            ngui.labelf("%.1fx Speed", timescale)
        }

        MAX_SPEED :: 200
        ent := entity.get(player.player.ent_id) or_else panic("Missing player entity in gui")
        if ngui.flex_row({0.2, 0.3, 0.1, 0.3, 0.1}) {
            ngui.labelf("Player")
            ngui.vec2(&ent.pos)
            ngui.labelf("Pos")
            ngui.vec2(&player.player.vel, min = -MAX_SPEED, max = MAX_SPEED, step = 0.1)
            ngui.labelf("Vel")
        }

        if ngui.flex_row({0.25, 0.25, 0.25, 0.25}) {
            ngui.labelf("Offset")
            ngui.vec2(&camera.offset)
            ngui.labelf("Zoom")
            ngui.float(&camera.zoom, min = 0, max = 10)
        }
    }

    rl.DrawFPS(rl.GetScreenWidth() - 80, 0)
}