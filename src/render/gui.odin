package render

import "core:fmt"
import rl "vendor:raylib"
import "../ngui"

tmp : f32

draw_gui :: proc() {
    rl.DrawFPS(rl.GetScreenWidth() - 80, 0)

    PAD :: 10
    W :: 200.0
    H :: 12.0
    X :: 5
    Y :: ngui.TITLE_HEIGHT + 1
    ngui.begin_panel("MyPanel", {0, 0, W + PAD, 6 * H})
        ngui.slider({X, 1 * H + Y, W * 0.8, H }, &tmp, 0, 100, fmt.ctprintf("%v", tmp))
        ngui.slider({X, 1 * H + Y, W * 0.8, H }, &tmp, 0, 100, fmt.ctprintf("%v", tmp))
    ngui.end_panel()
}