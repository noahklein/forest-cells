package render

import rl "vendor:raylib"
import "core:testing"

import "../entity"

graphics_layers : [Layer][dynamic]Graphic

Graphic :: struct {
    ent_id: entity.Id,
    shape: Shape,
    tint: rl.Color,
}

Shape :: enum u8 {
    Circle,
}

Layer :: enum u8 { BG, FG, UI }

init :: proc(size: int) {
    for layer in Layer do reserve(&graphics_layers[layer], size)
}

deinit :: proc() {
    for layer in Layer do delete(graphics_layers[layer])
}

// Add a new graphic to be rendered. A Graphic is destroyed if its ent_id is discovered to be invalid.
add :: proc(layer: Layer, gfx: Graphic) {
    append(&graphics_layers[layer], gfx)
}

draw :: proc(camera: rl.Camera2D) {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.WHITE)

    rl.BeginMode2D(camera)
        draw_layer(.BG)
        draw_layer(.FG)
        draw_layer(.UI)
    rl.EndMode2D()
}

draw_layer :: proc(layer: Layer) {
    graphics := &graphics_layers[layer]
    for i := 0; i < len(graphics); i += 1 {
        ent, ok := entity.get(graphics[i].ent_id)
        if !ok {
            unordered_remove(graphics, i)
            // This index is now occupied by what was the final graphic. Repeat this index.
            i -= 1
            continue
        }


        gfx := graphics[i]
        switch graphics[i].shape {
        case .Circle: rl.DrawCircleV(ent.pos, ent.scale, gfx.tint)
        }
    }
}