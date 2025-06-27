Circle :: struct {
    x, y, r: float;
}

Top    :: (using c: Circle) -> float { return y - r; }
Left   :: (using c: Circle) -> float { return x - r; }
Bottom :: (using c: Circle) -> float { return y + r; }
Right  :: (using c: Circle) -> float { return x + r; }

Center :: (using c: Circle) -> Vector2 {
    return .{ x, y };
}

ClosestPoint :: (a: Vector2, b: Circle) -> Vector2 {
      return ifx Colliding(a, b) then a else Center(b) + normalize(a - Center(b)) * b.r;
}

Colliding :: (a: Vector2, b: Circle) -> bool #symmetric {
    dx := a.x - b.x;
    dy := a.y - b.y;
    return (dx * dx) + (dy * dy) <= (b.r * b.r);
}

Colliding :: (a: Circle, b: Circle) -> bool {
    dx := a.x - b.x;
    dy := a.y - b.y;
    return (dx * dx) + (dy * dy) <= (a.r + b.r) * (a.r + b.r);
}

Colliding :: (a: Circle, b: Rectangle) -> bool #symmetric {
    closest_x := clamp(a.x, L(b), R(b));
    closest_y := clamp(a.y, T(b), B(b));
    return Colliding(a, Vector2.{ closest_x, closest_y });
}

Move :: (using c: *Circle, delta: Vector2) {
    x += delta.x;
    y += delta.y;
}

T :: Top;
L :: Left;
B :: Bottom;
R :: Right;
