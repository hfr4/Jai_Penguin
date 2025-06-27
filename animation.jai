Animation :: struct {
    frames:  [..] *Simp.Texture;
    index:   int;
    fps:     float;
    elapsed: float;
}

Init :: (animation: *Animation, fps: float, frames: [] *Simp.Texture) {
    animation.fps = fps;
    for frames  array_add(*animation.frames, it);
}

Update :: (using animation: *Animation, dt: float) {
    elapsed += dt;

    if elapsed >= 1.0 / fps  {
        elapsed = 0.0;

        index += 1;
        index %= frames.count;
    }
}

Reset :: (using animation: *Animation) {
    index   = 0;
    elapsed = 0.0;
}

DrawAnimation :: (using animation: Animation, position: Vector2, color := WHITE, flip := Flip_Flag.NONE, vertical_align := Vertical_Align.TOP, horizontal_align := Horizontal_Align.LEFT) {
	DrawTexture(frames[index], position, color, flip, vertical_align, horizontal_align);
}

DrawCenteredAnimation :: (using animation: Animation, position: Vector2, color := WHITE, flip := Flip_Flag.NONE) {
	DrawTexture(frames[index], position, color, flip, .CENTER, .CENTER);
}

animations: Table(string, Animation);

GetAnimation :: (name: string) -> *Animation {
    animation := table_find_pointer(*animations, name);
    assert(animation != null, "Can't find animation called : %", name);
    return animation;
}
