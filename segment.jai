Segment :: struct {
    a, b: Vector2;
}

SegmentFromPolar :: (p0: Vector2, angle: float, length: float) -> Segment {
    p1 := Vector2.{ p0.x + length * cos(angle), p0.y - length * sin(angle) };
    return .{ p0, p1 };
}

Center :: (using s: Segment) -> Vector2 {
    return (a + b) / 2;
}

Vector :: (using s: Segment) -> Vector2 {
    return b - a;
}

Direction :: (using s: Segment) -> Vector2 {
    return normalize(b - a);
}

Normal :: (using s: Segment) -> Vector2 {
    d := Direction(s);
    return .{ d.y, -d.x };
}

Angle :: (using s: Segment) -> float {
    return 0.0;
}

Length :: (using s: Segment) -> float {
    return length(b - a);
}

ClosestPoint :: (a: Vector2, b: Segment) -> Vector2 {
    v0 := Vector(b);
    v1 := a - b.a;

    projection := dot(v1, v0) / length_squared(v0);
    Clamp(*projection, 0, 1);

    return b.a + v0 * projection;
}

ClosestPoints :: (a: Segment, b: Segment) -> Vector2, Vector2 {
    v0 := Vector(a);
    v1 := Vector(b);
    v2 := b.a - a.a;

    d00 := dot(v0, v0);
    d01 := dot(v0, v1);
    d11 := dot(v1, v1);
    d20 := dot(v2, v0);
    d21 := dot(v2, v1);

    parallel := Direction(a) == Direction(b) || Direction(a) == -Direction(b);

    r0 := ifx parallel then 0                      else clamp((d20 * d01 - d21 * d00) / (d00 * d11 - d01 * d01), 0, 1);
    r1 := ifx parallel then clamp(d20 / d00, 0, 1) else clamp((d20 * d11 - d21 * d01) / (d00 * d11 - d01 * d01), 0, 1);

    ratio0 := clamp((r0 * d01 + d20) / d00, 0, 1);
    ratio1 := clamp((r1 * d01 - d21) / d11, 0, 1);

    coll0  := a.a + v0 * ratio0;
    coll1  := b.a + v1 * ratio1;

    return coll0, coll1;
}

Move :: (using s: *Segment, delta: Vector2) {
    a += delta;
    b += delta;
}