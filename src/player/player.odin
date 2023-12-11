package player

import "core:math/linalg"
import rl "vendor:raylib"
import "../entity"

player: Player

Player :: struct {
    ent_id: entity.Id,
    vel: rl.Vector2,
    grounded: bool,
}

PlayerInput :: enum {
    Left, Right,
    Jump,
}

get_input :: proc() -> (input: bit_set[PlayerInput]) {
         if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT)  do input += {.Left}
    else if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) do input += {.Right}

    if rl.IsKeyPressed(.SPACE) do input += {.Jump}

    return input
}

SPEED :: 100
FRICTION :: 0.95

update :: proc(input: bit_set[PlayerInput], dt: f32) {
    ent := entity.get(player.ent_id) or_else
        panic("player.update() called but player entity id is invalid")

    acc : rl.Vector2

         if .Left  in input do acc.x = -SPEED
    else if .Right in input do acc.x =  SPEED

    if .Jump in input && player.grounded {
        player.grounded = false
        acc.y = SPEED
    }

    // Friction
    if .Left not_in input && .Right not_in input {
        acc -= player.vel * FRICTION
    }

    player.vel += acc * dt
    ent.pos += player.vel * dt
}