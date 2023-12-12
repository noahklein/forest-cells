package ngui

import rl "vendor:raylib"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:time"

FONT :: 10
TEXT_COLOR :: rl.WHITE

TITLE_FONT :: 11
TITLE_HEIGHT :: 24
TITLE_COLOR :: rl.MAROON

DEFAULT_BUTTON_COLOR :: rl.DARKBLUE
HOVER_BUTTON_COLOR   :: rl.BLUE
ACTIVE_BUTTON_COLOR  :: rl.SKYBLUE

INPUT_PAD :: 2
INPUT_CURSOR_WIDTH  :: 5

SLIDER_WIDTH :: 16

button_color :: proc(hover, active: bool) -> rl.Color {
    if active {
        return ACTIVE_BUTTON_COLOR
    } else if hover {
        return HOVER_BUTTON_COLOR
    }
    return DEFAULT_BUTTON_COLOR
}

dark_color :: proc(hover, active: bool) -> rl.Color {
    if active {
        return {80, 80, 80, 255}
    } else if hover {
        return {40, 40, 40, 255}
    }
    return rl.BLACK
}

title_color :: proc(active: bool) -> rl.Color {
    return rl.RED if active else rl.MAROON
}

input_color :: proc(hover, active: bool) -> rl.Color {
    if active {
        return rl.BLACK
    } else if hover {
        return rl.BLACK + {15, 15, 15, 0}
    } else {
        return rl.BLACK + {45, 45, 45, 0}
    }
}

cursor_color :: proc(non_white := TEXT_COLOR) -> rl.Color {
    now := rl.GetTime()
    last_keypress_time :: 0 // @Incomplete
    t := math.cos(2 * f32(now - last_keypress_time))
    t *= t

    white := [4]f32{1, 1, 1, 1}
    non_white_vec := color_to_vec(non_white)
    color := linalg.lerp(white, non_white_vec, t)
    color *= 255
    return {u8(color.r), u8(color.g), u8(color.b), u8(color.a)}
}

color_to_vec :: proc(c: rl.Color) -> [4]f32 {
    return {
        f32(c.r) / 255, f32(c.g) / 255,
        f32(c.b) / 255, f32(c.a) / 255,
    }
}