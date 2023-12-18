package entity

import rl "vendor:raylib"

Graphic :: struct {
    layer: Layer,
    tint: rl.Color,
    shape: Shape,
}

Shape :: union {
    NoShape,
    Circle,
    Line,
    Rect,
}

NoShape :: struct{}
Circle  :: struct{ radius: f32 }
Line    :: struct{ end:  rl.Vector2 }
Rect    :: struct{ size: rl.Vector2 }

Layer :: enum u8 { BG, FG, UI }

draw :: proc(camera: rl.Camera2D) {
    rl.BeginMode2D(camera)
        for layer in Layer {
            draw_layer(layer)
        }
    rl.EndMode2D()
}

draw_layer :: proc(layer: Layer) {
    for ent, i in data.ents do if ent.age == data.ages[i] && ent.graphic.layer == layer {
        switch s in ent.graphic.shape {
            case NoShape: continue
            case Circle: rl.DrawCircleV(ent.pos, s.radius, ent.graphic.tint)
            case Line:   rl.DrawLineV(ent.pos, s.end, ent.graphic.tint)
            case Rect:   rl.DrawRectangleV(ent.pos, s.size, ent.graphic.tint)
        }
    }
}
