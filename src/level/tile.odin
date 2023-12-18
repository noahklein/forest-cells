package level

import "../entity"
import rl "vendor:raylib"

Tile :: struct{
    type: TileType,
    ent_id: entity.Id,
    time_in_state: f32,
    modified, occupied: bool,
}

TileType :: enum u8{
    Empty,
    Water,
    Dirt,
    FertileDirt,
    Grass,
    Poop,
}

TILE_COLORS := [TileType]rl.Color{
    .Empty = rl.DARKBROWN,
    .Water = rl.BLUE,
    .Dirt  = rl.BROWN,
    .FertileDirt  = rl.BROWN + {30, 30, 30, 0},
    .Grass = rl.GREEN,
    .Poop = rl.DARKGRAY,
}

Animal :: struct {
    ent_id: entity.Id,
    type: AnimalType,
    state: AnimalState,
    health: int,
}

AnimalType :: enum {
    Rabbit,
}

ANIMAL_FOOD := [AnimalType]TileType{
    .Rabbit = .Grass,
}

// Find food tile:
//      if fail -> take damage, remain in state
//      else    -> Set food tile as target, mark tile as occupied, go to Move{Eat} state
// Move: interpolate towards tile (pathfinding?), continue to next state
// Eat: play eating animation, change tile to poop when finished, go to Find Food state.

// Poop takes a long time to become FertileSoil.
AnimalState :: union #no_nil {
    FindFood,
    Move,
    Eat,
    Dead,
}

FindFood :: struct{}
Move     :: struct{ target: int, duration: f32 }
Eat      :: struct{ target: int, }
Dead     :: struct{}

animal_spawn :: proc(level: ^Level, type: AnimalType) -> entity.Id {
    ANIMAL_SPAWN :: rl.Vector2{0, 400}
    id := entity.create(entity.Entity{
        pos = ANIMAL_SPAWN,
        graphic = {.UI, rl.SKYBLUE, entity.Circle{ 30 } },
    })

    append(&level.animals, Animal{
        ent_id = id,
        type = type,
        health = 10,
        state = FindFood{},
    })

    return id
}