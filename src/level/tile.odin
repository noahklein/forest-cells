package level

import "../entity"

Tile :: struct{
    type: TileType,
    ent_id: entity.Id,
}

TileType :: union{
    Dirt, Water,
}

Dirt :: struct{
    fertile: bool,
}

Water :: struct {}