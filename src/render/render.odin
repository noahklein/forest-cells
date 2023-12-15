package render

import rl "vendor:raylib"

import "../entity"

graphics_layers : [Layer][dynamic]Graphic

Graphic :: struct {
    ent_id: entity.Id,
    tint: rl.Color,
    shape: Shape,
}

Shape :: union {
    Circle,
    Line,
    Rect,
}

Circle :: struct{ radius: f32 }
Line   :: struct{ end:  rl.Vector2 }
Rect   :: struct{ size: rl.Vector2 }

Layer :: enum u8 { BG, FG, UI }

init :: proc(size_per_layer: int) {
    for layer in Layer do reserve(&graphics_layers[layer], size_per_layer)
}

deinit :: proc() {
    for layer in Layer do delete(graphics_layers[layer])
}

// Add a new graphic to be rendered. A Graphic is destroyed if its ent_id is discovered to be invalid.
add :: proc(layer: Layer, gfx: Graphic) {
    append(&graphics_layers[layer], gfx)
}

draw :: proc(camera: rl.Camera2D) {
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
        switch s in graphics[i].shape {
        case Circle: rl.DrawCircleV(ent.pos, s.radius, gfx.tint)
        case Line: rl.DrawLineV(ent.pos, s.end, gfx.tint)
        case Rect: rl.DrawRectangleV(ent.pos, s.size, gfx.tint)
        }
    }
}