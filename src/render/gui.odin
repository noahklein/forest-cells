package render

import "core:fmt"
import rl "vendor:raylib"
import "../ngui"

tmp_a, tmp_b : f32
tmp_v1, tmp_v2 : rl.Vector2

draw_gui :: proc() {
    rl.DrawFPS(rl.GetScreenWidth() - 80, 0)

    ngui.begin_panel("MyPanel", {0, 0, 200, 0})
        ngui.slider(&tmp_a, 0, 100)
        ngui.slider(&tmp_b, 11, 35)
        ngui.button("Push me")
        ngui.vec2(&tmp_v1)
        ngui.vec2(&tmp_v2, -50, 75, step = 2)
    ngui.end_panel()
}