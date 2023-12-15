package main

import rl "vendor:raylib"
import "ngui"
import "entity"

str: string
Radio :: enum {
    One,
    Two,
    Three,
}
rb1: Radio
rb2: Radio
Checkbox :: enum {
    Fire, Water, Earth, Air,
}
bs1, bs2: bit_set[Checkbox]

draw_gui :: proc() {
    ngui.update()

    if ngui.begin_panel("Game", {0, 0, 400, 0}) {
        if ngui.flex_row({0.7, 0.2}) {
            ngui.slider(&timescale, 0, 10)
            ngui.text("%.1fx Speed", timescale)
        }

        if ngui.flex_row({0.2, 0.3, 0.3, 0.2}) {
            ngui.text("Camera")
            ngui.vec2(&camera.offset, label = "Offset")
            ngui.vec2(&camera.target, label = "Target")
            ngui.float(&camera.zoom, min = 0, max = 10, label = "Zoom")
        }

        if ngui.flex_row({1}) {
            ngui.input(&str, "Input")
        }

        if ngui.flex_row({0.5, 0.5}) {
            ngui.flags(&bs1, label = "Checkbox")
            ngui.flags(&bs2)
        }

        if ngui.flex_row({0.5, 0.5}) {
            ngui.radio_group(Radio, &rb1)
            ngui.radio_group(Radio, &rb2, label = "Radio")
        }
    }

    rl.DrawFPS(rl.GetScreenWidth() - 80, 0)
}