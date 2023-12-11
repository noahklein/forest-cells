package render

import "core:fmt"
import rl "vendor:raylib"
import "../ngui"
import "../player"
import "../entity"

tmp_a, tmp_b : f32
tmp_v1, tmp_v2 : rl.Vector2

draw_gui :: proc() {
    if ngui.begin_panel("MyPanel", {0, 0, 320, 0}) {
        if ngui.flex_row({1}) {
            ngui.button("hello")
        }
        if ngui.flex_row({0.5, 0.5}) {
            ngui.slider(&tmp_a, 0, 100)
            ngui.slider(&tmp_b, 0, 100)
        }

        if ngui.flex_row({0.25, 0.25, 0.25, 0.25}) {
            if ngui.button("Prev") {
                tmp_v1 -= {1, 1}
            }
            if ngui.button("Next") {
                tmp_v1 += {1, 1}
            }

            ngui.vec2(&tmp_v1)
            ngui.vec2(&tmp_v2, min = -50, max = 75, step = 1)
        }
    }

    if ngui.begin_panel("Game", {1290, 20, 300, 0}) {
        if ngui.flex_row({0.7, 0.2}) {
            ngui.slider(&tmp_a, 0, 100)
            ngui.labelf("%.1fx Speed", tmp_a)
        }

        MAX_SPEED :: 20
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