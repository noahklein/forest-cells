package ngui

import rl "vendor:raylib"

FONT :: 10
TEXT_COLOR :: rl.BLACK

TITLE_FONT :: 11
TITLE_HEIGHT :: 24
TITLE_COLOR :: rl.MAROON

DEFAULT_BUTTON_COLOR :: rl.DARKBLUE
HOVER_BUTTON_COLOR   :: rl.BLUE
ACTIVE_BUTTON_COLOR  :: rl.SKYBLUE

SLIDER_WIDTH :: 16

button_color :: proc(hovered, active: bool) -> rl.Color {
    if active {
        return ACTIVE_BUTTON_COLOR
    } else if hovered {
        return HOVER_BUTTON_COLOR
    }
    return DEFAULT_BUTTON_COLOR
}

dark_color :: proc(hovered, active: bool) -> rl.Color {
    if active {
        return {80, 80, 80, 255}
    } else if hovered {
        return {40, 40, 40, 255}
    }
    return rl.BLACK
}

title_color :: proc(active: bool) -> rl.Color {
    return rl.RED if active else rl.MAROON
}