DrawPolygon :: (vertices: [] Vector2, color := WHITE) {
    transform := GetCurrentTransform();

    Simp.set_shader_for_color(enable_blend = true);

    for j: 1..vertices.count - 2 {
        k := (j + 1) % vertices.count;

        vi := TransformVertex(vertices[0], transform);
        vj := TransformVertex(vertices[j], transform);
        vk := TransformVertex(vertices[k], transform);

        Simp.immediate_triangle(.{ vi.x, vi.y, 0 }, .{ vj.x, vj.y, 0 }, .{ vk.x, vk.y, 0 }, color, color, color);
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

Horizontal_Align :: enum {
    LEFT;
    RIGHT;
    CENTER;
}

Vertical_Align :: enum {
    TOP;
    BOTTOM;
    CENTER;
}

Flip_Flag :: enum_flags {
    NONE;
    HORIZONTAL;
    VERTICAL;
}

DrawText :: (font: *Simp.Dynamic_Font, text: string, position: Vector2, color := WHITE, vertical_align := Vertical_Align.TOP, horizontal_align := Horizontal_Align.LEFT, effects : Simp.Font_Effects = 0) {
    w := Simp.prepare_text(font, text);
    h := font.character_height / 2.0;
    x : float;
    y : float;

    if horizontal_align == {
        case .LEFT;    x = position.x;
        case .RIGHT;   x = position.x - w;
        case .CENTER;  x = position.x - w / 2.0;
    }

    if vertical_align == {
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

DrawCenteredText :: (font: *Simp.Dynamic_Font, text: string, position: Vector2, color := WHITE, effects : Simp.Font_Effects = 0) {
    DrawText(font, text, position, color, .CENTER, .CENTER, effects);
}

DrawTexture :: (texture: Simp.Texture, position: Vector2, color := WHITE, flip := Flip_Flag.NONE, vertical_align := Vertical_Align.TOP, horizontal_align := Horizontal_Align.LEFT) {
    w := cast(float) texture.width;
    h := cast(float) texture.height;
    x : float;
    y : float;

    if horizontal_align == {
        case .LEFT;    x = position.x;
        case .RIGHT;   x = position.x - w;
        case .CENTER;  x = position.x - w / 2.0;
    }

    if vertical_align == {
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

DrawCenteredTexture :: (texture: Simp.Texture, position: Vector2, color := WHITE, flip := Flip_Flag.NONE) {
    DrawTexture(texture, position, color, flip, .CENTER, .CENTER);
}

Transform :: struct {
    translation : Vector2;
    rotation    : float;
    scale       : float;
}

transforms: [..] Transform;

TransformVertex :: (vertex: Vector2, using transform: Transform) -> Vector2 #expand {
    return rotate(vertex, rotation) * scale + translation;
}

PushTransform :: (transform: Transform) {
    array_add(*transforms, transform);
}

PushTranlation :: (offset: Vector2) {
    transform := array_add(*transforms);
    transform.translation = offset;
}

PushRotation :: (angle: float) {
    transform := array_add(*transforms);
    transform.rotation = angle;
}

PushScale :: (scale: float) {
    transform := array_add(*transforms);
    transform.scale = scale;
}

PopTransform :: () {
    pop(*transforms);
}

PushTransformThisScope :: (transform: Transform) #expand {
    `PushTransform(transform);
    `defer PopTransform();
}

PushTranslationThisScope :: (offset: Vector2) #expand {
    `PushTranlation(offset);
    `defer PopTransform();
}

PushRotationThisScope :: (angle: float) #expand {
    `PushRotation(angle);
    `defer PopTransform();
}

PushScaleThisScope :: (scale: float) #expand {
    `PushScale(scale);
    `defer PopTransform();
}

GetCurrentTransform :: () -> Transform {
    current: Transform;
    current.scale = 1.0;

    for transforms {
        current.translation += it.translation;
        current.rotation    += it.rotation;
        current.scale       += it.scale;
    }

    return current;
}

WHITE  :: Vector4.{ 1., 1., 1., 1. };
BLACK  :: Vector4.{ 0., 0., 0., 1. };
RED    :: Vector4.{ .9, .1, .2, 1. };
GREEN  :: Vector4.{ 0., .8, .1, 1. };
BLUE   :: Vector4.{ 0., .4, .9, 1. };
YELLOW :: Vector4.{ .9, .9, 0., 1. };
PINK   :: Vector4.{ 1., .4, .7, 1. };
ORANGE :: Vector4.{ 1., .6, 0., 1. };
BROWN  :: Vector4.{ .4, .4, .3, 1. };

POINTS_PER_CIRCLE :: 50;