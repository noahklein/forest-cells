package entity

import rl "vendor:raylib"
import "core:testing"

Entity :: struct {
    age: u16,
    using transform: Transform,
    graphic: Graphic,
    disabled: bool,
}

Transform :: struct {
    pos: rl.Vector2,
    rot: f32,
}

Id :: struct {
    index, age: u16,
}

Storage :: struct {
    ents: [dynamic]Entity,
    ages: [dynamic]u16, // Parallel with ents.
}

data: Storage

init :: proc(size: int) {
    reserve(&data.ents, size)
    reserve(&data.ages, size)
}

deinit :: proc() {
    delete(data.ents)
    delete(data.ages)
}

create :: proc(e: Entity) -> Id {
    // Search for deleted slot.
    for ent, i in data.ents {
        if ent.age != data.ages[i] {
            data.ents[i] = e
            data.ents[i].age = data.ages[i]
            return {index = u16(i), age = data.ages[i]}
        }
    }

    // No empty slots.
    append(&data.ents, e)
    append(&data.ages, 0)
    return { index = u16(len(data.ents) - 1), age = 0 }
}

destroy :: proc(id: Id) {
    if id.age == data.ages[id.index] {
        data.ages[id.index] += 1
    }
}

@(require_results)
get :: #force_inline proc(id: Id) -> (^Entity, bool) {
    if data.ages[id.index] != id.age {
        return nil, false
    }
    return &data.ents[id.index], true
}

@(test)
test_storage :: proc(t: ^testing.T) {
    init(2)

    want_pos := rl.Vector2{10, 13}
    id := create({pos = want_pos})
    if ent, ok := get(id); !ok || ent.pos != want_pos {
        testing.error(t, "Failed to get entity after create")
    }

    destroy(id)
    if ent, ok := get(id); ok {
        testing.error(t, "Got entity after destroy")
    }

    new_pos := rl.Vector2{1, 2}
    new_id := create({pos = new_pos})
    if new_id.index != id.index {
        testing.error(t, "Failed to reuse deleted entity slot")
    }
    if new_id.age != id.age + 1 {
        testing.errorf(t, "Age should only increment by one after destroy-create: want %d, got %d", new_id.age, id.age + 1)
    }
    if ent, ok := get(id); ok {
        testing.error(t, "Destroyed id is working again after create")
    }
    if ent, ok := get(new_id); !ok || ent.pos != new_pos {
        testing.error(t, "Failed to get new entity after destroy create")
    }
}
