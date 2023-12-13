package main

import rl "vendor:raylib"
import "ngui"
import "player"
import "entity"

tmp_a, tmp_b : f32
tmp_v1, tmp_v2 : rl.Vector2
my_str, my_other_str: string
my_bool : bool


E :: enum{One, Two, Three, Four}
e : E
O :: enum{Foo, Bar}
o : O

draw_gui :: proc() {
    ngui.update()

    if ngui.begin_panel("Grid", {0, 0, 320, 0}) {
        if ngui.flex_row({0.25, 0.25, 0.5}) {
            if ngui.button("Less") {
                lvl._grid.size -= 1
            }
            if ngui.button("More") {
                lvl._grid.size += 1
            }
            ngui.vec2(&lvl._grid.size, min = 0, step = 1)
        }
    }

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
    }

    rl.DrawFPS(rl.GetScreenWidth() - 80, 0)
}