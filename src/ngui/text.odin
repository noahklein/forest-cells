package ngui

import rl "vendor:raylib"
import "core:fmt"
import "core:strings"

TextInput :: struct {
    buf: strings.Builder,
}

TextAlign :: enum {
    Left,
    Center,
    Right,
}

labelf :: proc($format: string, args: ..any, color := TEXT_COLOR, align := TextAlign.Left) {
    rect := flex_rect()

    text := fmt.ctprintf(format, ..args)
    label_rect(rect, text, color, align)
}

label_rect :: proc(rect: rl.Rectangle, text: cstring, color := TEXT_COLOR, align := TextAlign.Left) {
    y := rect.y + (rect.height / 2) - (f32(FONT) / 2)

    x : f32
    switch align {
    case .Left:   x = rect.x
    case .Center: x = rect.x + (rect.width / 2) - f32(rl.MeasureText(text, FONT)) / 2
    case .Right:  x = (rect.x + rect.width) - f32(rl.MeasureText(text, FONT))
    }

    rl.DrawText(text, i32(x), i32(y), FONT, color)
}

input :: proc(text: ^string, $label: cstring) {
    rect := flex_rect()
    input_rect(rect, text, label)
}

input_rect :: proc(rect: rl.Rectangle, text: ^string, label: cstring) {
    key := fmt.ctprintf("%s#input", label)
    active := state.active_input == key

    // Initialize text input.
    if key not_in state.text_inputs {
        state.text_inputs[key] = TextInput{
            buf = strings.builder_make(0, 64),
        }
    }
    input := &state.text_inputs[key]

    hover := hovered(rect)
    if !active && hover && rl.IsMouseButtonPressed(.LEFT) {
        state.active_input = key

        strings.builder_reset(&input.buf)

        for char in text^ {
            fmt.sbprint(&input.buf, char)
        }
    }

    if active {
        // Lose focus when you click away.
        if !hover && rl.IsMouseButtonPressed(.LEFT) {
            state.active_input = nil
            return
        }

        // Get keyboard input.
        for char := rl.GetCharPressed(); char != 0; char = rl.GetCharPressed() {
            state.last_keypress_time = rl.GetTime()
            strings.write_rune(&input.buf, char)
        }

        // Backspace to delete.
        if strings.builder_len(input.buf) > 0 && rl.IsKeyPressed(.BACKSPACE) {
            strings.pop_rune(&input.buf) // Always delete one character.

            // Ctrl+Backspace deletes entire words.
            if rl.IsKeyDown(.LEFT_CONTROL) {
                for strings.builder_len(input.buf) > 0 {
                    c, _ := strings.pop_rune(&input.buf)

                    switch c {
                    // Stop characters divide words.
                    case ' ', '-' ,'_': return
                    case:
                    }
                }
            }
        }
        // Ctrl+U clears whole buffer like UNIX terminals.
        if rl.IsKeyDown(.LEFT_CONTROL) && rl.IsKeyPressed(.U) {
            strings.builder_reset(&input.buf)
        }
    }

    rl.DrawRectangleRec(rect, input_color(hover, active))

    text^ = strings.to_string(input.buf)
    cstr := strings.clone_to_cstring(text^, context.temp_allocator)
    text_rect := padding(rect, {INPUT_PAD, INPUT_PAD})
    label_rect(text_rect, cstr)

    // Cursor
    if active {
        cursor_rect := text_rect
        cursor_rect.x += f32(rl.MeasureText(cstr, FONT))
        cursor_rect.width = INPUT_CURSOR_WIDTH
        rl.DrawRectangleRec(cursor_rect, cursor_color())
    }
}