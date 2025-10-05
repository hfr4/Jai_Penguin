DrawPolygon :: (vertices: [] Vector2, color := WHITE) {
    transform := GetCurrentTransform();

    Simp.set_shader_for_color(enable_blend = true);

    for j: 1..vertices.count - 2 {
        k := (j + 1) % vertices.count;

        v0 := TransformVertex(vertices[0], transform);
        v1 := TransformVertex(vertices[j], transform);
        v2 := TransformVertex(vertices[k], transform);

        Simp.immediate_triangle(.{ v0.x, v0.y, 0 }, .{ v1.x, v1.y, 0 }, .{ v2.x, v2.y, 0 }, color, color, color);
    }
}

DrawPoint :: (using point: Vector2, color := WHITE, size := 1.0) {
    half := Vector2.{ size / 2.0, size / 2.0 };
    rect := RectangleFromPoints(point - half, point + half);
    DrawRectangle(rect, color);
}

DrawSegment :: (using segment: Segment, color := WHITE, width := 1.0) {
    n := Normal(segment) * (width / 2.0);
    DrawPolygon(.[ a - n, a + n, b + n, b - n ], color);
}

DrawRectangle :: (using rectangle: Rectangle, color := WHITE) {
    DrawPolygon(.[ TL(rectangle), TR(rectangle), BR(rectangle), BL(rectangle) ], color);
}

DrawCircle :: (using circle: Circle, color := WHITE) {
    THETA :: TAU / POINTS_PER_CIRCLE;
    vertices : [POINTS_PER_CIRCLE] Vector2;
    for i: 0..POINTS_PER_CIRCLE - 1 {
        vertices[i] = Center(circle) + Vector2.{ cos(THETA * i), sin(THETA * i) } * r;
    }
    DrawPolygon(vertices, color);
}

DrawEllipse :: (center: Vector2, w: float, h: float, color := WHITE) {
    THETA :: TAU / POINTS_PER_CIRCLE;
    vertices : [POINTS_PER_CIRCLE] Vector2;
    for i: 0..POINTS_PER_CIRCLE - 1 {
        vertices[i] = center + Vector2.{ cos(THETA * i) * w, sin(THETA * i) * h };
    }
    DrawPolygon(vertices, color);
}

DrawPolygonFill   :: DrawPolygon;
DrawRectangleFill :: DrawRectangle;
DrawCircleFill    :: DrawCircle;
DrawEllipseFill   :: DrawEllipse;

DrawPolygonLine :: (vertices: [] Vector2, color := WHITE, width := 1.0) {
    for i: 0..vertices.count - 1 {
        j := (i + 1) % vertices.count;
        DrawSegment(.{ vertices[i], vertices[j] }, color, width);
    }
}

DrawRectangleLine :: (using rectangle: Rectangle, color := WHITE, width := 1.0) {
    DrawPolygonLine(.[ TL(rectangle), TR(rectangle), BR(rectangle), BL(rectangle) ], color, width);
}

DrawCircleLine :: (using circle: Circle, color := WHITE, width := 1.0) {
    THETA :: TAU / POINTS_PER_CIRCLE;
    vertices : [POINTS_PER_CIRCLE] Vector2;
    for i: 0..POINTS_PER_CIRCLE - 1 {
        vertices[i] = Center(circle) + Vector2.{ cos(THETA * i), sin(THETA * i) } * r;
    }
    DrawPolygonLine(vertices, color);
}

DrawEllipseLine :: (center: Vector2, w: float, h: float, color := WHITE, width := 1.0) {
    THETA :: TAU / POINTS_PER_CIRCLE;
    vertices : [POINTS_PER_CIRCLE] Vector2;
    for i: 0..POINTS_PER_CIRCLE - 1 {
        vertices[i] = center + Vector2.{ cos(THETA * i) * w, sin(THETA * i) * h };
    }
    DrawPolygonLine(vertices, color, width);
}

Align :: struct {
    v: enum { TOP; BOTTOM; CENTER; } = .TOP;
    h: enum { LEFT; RIGHT; CENTER; } = .LEFT;
}

Flip_Flag :: enum_flags {
    NONE;
    HORIZONTAL;
    VERTICAL;
}

DrawText :: (font: *Simp.Dynamic_Font, text: string, position: Vector2, color := WHITE, align := Align.{ .TOP, .LEFT }, effects : Simp.Font_Effects = 0) {
    w := Simp.prepare_text(font, text);
    h := font.character_height / 2.0;
    x : float;
    y : float;

    if align.h == {
        case .LEFT;    x = position.x;
        case .RIGHT;   x = position.x - w;
        case .CENTER;  x = position.x - w / 2.0;
    }

    if align.v == {
        case .BOTTOM;  y = position.y;
        case .TOP;     y = position.y + h;
        case .CENTER;  y = position.y + h / 2.0;
    }

    Simp.generate_quads_for_prepared_text(font, cast(s64) x, cast(s64) y, effects);

    transform := GetCurrentTransform();

    for * font.current_quads {
        it.p0 = TransformVertex(it.p0, transform);
        it.p1 = TransformVertex(it.p1, transform);
        it.p2 = TransformVertex(it.p2, transform);
        it.p3 = TransformVertex(it.p3, transform);
    }

    Simp.draw_generated_quads(font, color);
}

DrawTextCentered :: (font: *Simp.Dynamic_Font, text: string, position: Vector2, color := WHITE, effects : Simp.Font_Effects = 0) {
    DrawText(font, text, position, color, .{ .CENTER, .CENTER }, effects);
}

DrawTexture :: (texture: Simp.Texture, position: Vector2, color := WHITE, flip := Flip_Flag.NONE, align := Align.{ .TOP, .LEFT }) {
    w := cast(float) texture.width;
    h := cast(float) texture.height;
    x : float;
    y : float;

    if align.h == {
        case .LEFT;    x = position.x;
        case .RIGHT;   x = position.x - w;
        case .CENTER;  x = position.x - w / 2.0;
    }

    if align.v == {
        case .TOP;     y = position.y;
        case .BOTTOM;  y = position.y - h;
        case .CENTER;  y = position.y - h / 2.0;
    }

    x0 := x;
    y0 := y;
    x1 := x + w;
    y1 := y + h;

    if flip & .HORIZONTAL Swap(*x0, *x1);
    if flip & .VERTICAL   Swap(*y0, *y1);

    transform := GetCurrentTransform();

    p0 := TransformVertex(.{ x0, y0 }, transform);
    p1 := TransformVertex(.{ x1, y0 }, transform);
    p2 := TransformVertex(.{ x1, y1 }, transform);
    p3 := TransformVertex(.{ x0, y1 }, transform);

    Simp.set_shader_for_images(*texture);
    Simp.immediate_quad(p0, p1, p2, p3, color);
}

DrawTexture :: (texture: Simp.Texture, rectangle: Rectangle, color := WHITE, flip := Flip_Flag.NONE) {
    position := TL(rectangle);

    x0 := L(rectangle);
    y0 := T(rectangle);
    x1 := R(rectangle);
    y1 := B(rectangle);

    if flip & .HORIZONTAL Swap(*x0, *x1);
    if flip & .VERTICAL   Swap(*y0, *y1);

    transform := GetCurrentTransform();

    p0 := TransformVertex(.{ x0, y0 }, transform);
    p1 := TransformVertex(.{ x1, y0 }, transform);
    p2 := TransformVertex(.{ x1, y1 }, transform);
    p3 := TransformVertex(.{ x0, y1 }, transform);

    Simp.set_shader_for_images(*texture);
    Simp.immediate_quad(p0, p1, p2, p3, color);
}

DrawTextureCentered :: (texture: Simp.Texture, position: Vector2, color := WHITE, flip := Flip_Flag.NONE) {
    DrawTexture(texture, position, color, flip, .{ .CENTER, .CENTER });
}

DrawAnimation :: (using animation: Animation, position: Vector2, color := WHITE, flip := Flip_Flag.NONE, align := Align.{ .TOP, .LEFT }) {
	DrawTexture(frames[index].texture, position, color, flip, align);
}

DrawAnimation :: (using animation: Animation, rectangle: Rectangle, color := WHITE, flip := Flip_Flag.NONE) {
	DrawTexture(frames[index].texture, rectangle, color, flip);
}

DrawAnimationCentered :: (using animation: Animation, position: Vector2, color := WHITE, flip := Flip_Flag.NONE) {
	DrawTexture(frames[index].texture, position, color, flip, .{ .CENTER, .CENTER });
}

Transform :: struct {
    translation : Vector2;
    rotation    : float;
    scale       := 1.0;
}

transforms: [..] Transform;

TransformVertex :: (vertex: Vector2, matrix: Matrix4) -> Vector2 #expand {
    v := matrix * Vector4.{ vertex.x, vertex.y, 0.0, 1.0 } ;
    return .{ v.x, v.y };
}

PushTransform :: (transform: Transform) {
    array_add(*transforms, transform);
}

PushTranlation :: (tra: Vector2) {
    transform := array_add(*transforms);
    transform.translation = tra;
}

PushRotation :: (rot: float) {
    transform := array_add(*transforms);
    transform.rotation = rot;
}

PushScale :: (sca: float) {
    transform := array_add(*transforms);
    transform.scale = sca;
}

PopTransform :: () {
    pop(*transforms);
}

PushTransformThisScope :: (transform: Transform) #expand {
    PushTransform(transform);
    `defer PopTransform();
}

PushTranslationThisScope :: (translation: Vector2) #expand {
    PushTranlation(translation);
    `defer PopTransform();
}

PushRotationThisScope :: (angle: float) #expand {
    PushRotation(angle);
    `defer PopTransform();
}

PushScaleThisScope :: (scale: float) #expand {
    PushScale(scale);
    `defer PopTransform();
}

GetCurrentTransform :: () -> Matrix4 {
    result := Matrix4_Identity;

    for transforms {
        result *= TransformToMatrix4(it);
    }

    return result;
}

TransformToMatrix4 :: (using transform: Transform) -> Matrix4 {
    result := Matrix4_Identity;

    c := scale * cos(rotation);
    s := scale * sin(rotation);

    result.floats[0] = c;
    result.floats[1] = -s;
    result.floats[3] = translation.x;

    result.floats[4] = s;
    result.floats[5] = c;
    result.floats[7] = translation.y;

    return result;
}

POINTS_PER_CIRCLE :: 50;