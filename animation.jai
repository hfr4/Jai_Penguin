Animation :: struct {
    frames:  [..] Frame;
    index:   int;
    elapsed: float;
}

Frame :: struct {
    texture:  *Simp.Texture;
    duration: float;
}

InitAnimation :: (name: string, frames: [] Frame) {
    if !table_find_pointer(*animations, name) {
        animation: Animation;
        array_copy(*animation.frames, frames);
        table_add(*animations, name, animation);
    }
}

Update :: (using animation: *Animation, dt: float) {
    elapsed += dt;

    if elapsed >= frames[index].duration {
        elapsed = 0.0;
        index   = (index + 1) % frames.count;
    }
}

Reset :: (using animation: *Animation) {
    index   = 0;
    elapsed = 0.0;
}

GetAnimation :: (name: string) -> *Animation {
    animation := table_find_pointer(*animations, name);
    assert(animation != null, "Can't find animation called : %", name);
    return animation;
}

#scope_file

animations: Table(string, Animation);
