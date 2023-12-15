package level

import "../entity"
import rl "vendor:raylib"

Tile :: struct{
    type: TileType,
    ent_id: entity.Id,
    modified: bool,
}

TileType :: enum u8{
    Empty,
    Water,
    Dirt,
    FertileDirt,
    Grass,
}

TILE_COLORS := [TileType]rl.Color{
    .Empty = rl.BLACK,
    .Water = rl.BLUE,
    .Dirt  = rl.BROWN,
    .FertileDirt  = rl.BROWN + {20, 20, 20, 0},
    .Grass = rl.GREEN,
}

Animal :: struct {
    ent_id: entity.Id,
    type: AnimalType,
    hungry: bool,
}

AnimalType :: enum {
    Rabbit,
}