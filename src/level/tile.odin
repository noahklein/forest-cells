package level

import "../entity"
import rl "vendor:raylib"

Tile :: struct{
    type: TileType,
    ent_id: entity.Id,
}

TileType :: enum u8{
    Empty,
    Dirt,
    Water,
}

TileContent :: enum u8 {
    Grass,
    Tree,
}

TILE_COLORS := [TileType]rl.Color{
    .Empty = rl.BLACK,
    .Dirt  = rl.BROWN,
    .Water = rl.BLUE,

}