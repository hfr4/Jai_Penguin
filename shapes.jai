Rectangle :: struct {
    x, y, w, h: float;
}

RectangleFromPoints :: (a: Vector2, b: Vector2) -> Rectangle {
    x := min(a.x, b.x);
    y := min(a.y, b.y);
    w := max(a.x, b.x) - min(a.x, b.x);
    h := max(a.y, b.y) - min(a.y, b.y);

    return .{ x, y, w, h };
}

Union :: (a: Rectangle, b: Rectangle) -> Rectangle {
    tl := Vector2.{ min(L(a), L(b)), min(T(a), T(b)) };
    br := Vector2.{ max(R(a), R(b)), max(B(a), B(b)) };

    return RectangleFromPoints(tl, br);
}

Intersection :: (a: Rectangle, b: Rectangle) -> bool, Rectangle {
    if !Colliding(a, b) return false, .{};

    tl := Vector2.{ max(L(a), L(b)), max(T(a), T(b)) };
    br := Vector2.{ min(R(a), R(b)), min(B(a), B(b)) };

    return true, RectangleFromPoints(tl, br);
}

Top             :: (using r: Rectangle) -> float { return y;         }
Left            :: (using r: Rectangle) -> float { return x;         }
Bottom          :: (using r: Rectangle) -> float { return y + h;     }
Right           :: (using r: Rectangle) -> float { return x + w;     }
CenterX         :: (using r: Rectangle) -> float { return x + w / 2; }
CenterY         :: (using r: Rectangle) -> float { return y + h / 2; }

TopLeft         :: (using r: Rectangle) -> Vector2 { return .{ L(r) , T(r)  }; }
TopRight        :: (using r: Rectangle) -> Vector2 { return .{ R(r) , T(r)  }; }
BottomLeft      :: (using r: Rectangle) -> Vector2 { return .{ L(r) , B(r)  }; }
BottomRight     :: (using r: Rectangle) -> Vector2 { return .{ R(r) , B(r)  }; }
Center          :: (using r: Rectangle) -> Vector2 { return .{ CX(r), CY(r) }; }
CenterTop       :: (using r: Rectangle) -> Vector2 { return .{ CX(r), T(r)  }; }
CenterLeft      :: (using r: Rectangle) -> Vector2 { return .{ L(r) , CY(r) }; }
CenterBottom    :: (using r: Rectangle) -> Vector2 { return .{ CX(r), B(r)  }; }
CenterRight     :: (using r: Rectangle) -> Vector2 { return .{ R(r) , CY(r) }; }

Size            :: (using r: Rectangle) -> Vector2 { return .{ w    , h     }; }
HalfSize        :: (using r: Rectangle) -> Vector2 { return .{ w / 2, h / 2 }; }

SetTop          :: (using r: *Rectangle, pos: float) { y = pos;         }
SetLeft         :: (using r: *Rectangle, pos: float) { x = pos;         }
SetBottom       :: (using r: *Rectangle, pos: float) { y = pos - h;     }
SetRight        :: (using r: *Rectangle, pos: float) { x = pos - w;     }
SetCenterX      :: (using r: *Rectangle, pos: float) { x = pos - w / 2; }
SetCenterY      :: (using r: *Rectangle, pos: float) { y = pos - h / 2; }

SetTopLeft      :: (using r: *Rectangle, pos: Vector2) { SetL(r, pos.x);  SetT(r, pos.y);  }
SetTopRight     :: (using r: *Rectangle, pos: Vector2) { SetR(r, pos.x);  SetT(r, pos.y);  }
SetBottomLeft   :: (using r: *Rectangle, pos: Vector2) { SetL(r, pos.x);  SetB(r, pos.y);  }
SetBottomRight  :: (using r: *Rectangle, pos: Vector2) { SetR(r, pos.x);  SetB(r, pos.y);  }
SetCenter       :: (using r: *Rectangle, pos: Vector2) { SetCX(r, pos.x); SetCY(r, pos.y); }
SetCenterTop    :: (using r: *Rectangle, pos: Vector2) { SetCX(r, pos.x); SetT(r, pos.y);  }
SetCenterLeft   :: (using r: *Rectangle, pos: Vector2) { SetL(r, pos.x);  SetCY(r, pos.y); }
SetCenterBottom :: (using r: *Rectangle, pos: Vector2) { SetCX(r, pos.x); SetB(r, pos.y);  }
SetCenterRight  :: (using r: *Rectangle, pos: Vector2) { SetR(r, pos.x);  SetCY(r, pos.y); }

Move :: (using r: *Rectangle, delta: Vector2) {
    x += delta.x;
    y += delta.y;
}

T     :: Top;
L     :: Left;
B     :: Bottom;
R     :: Right;
CX    :: CenterX;
CY    :: CenterY;

TL    :: TopLeft;
TR    :: TopRight;
BL    :: BottomLeft;
BR    :: BottomRight;
C     :: Center;
CT    :: CenterTop;
CL    :: CenterLeft;
CB    :: CenterBottom;
CR    :: CenterRight;

SetT  :: SetTop;
SetL  :: SetLeft;
SetB  :: SetBottom;
SetR  :: SetRight;
SetCX :: SetCenterX;
SetCY :: SetCenterY;

SetTL :: SetTopLeft;
SetTR :: SetTopRight;
SetBL :: SetBottomLeft;
SetBR :: SetBottomRight;
SetC  :: SetCenter;
SetCT :: SetCenterTop;
SetCL :: SetCenterLeft;
SetCB :: SetCenterBottom;
SetCR :: SetCenterRight;


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

Move :: (using c: *Circle, delta: Vector2) {
    x += delta.x;
    y += delta.y;
}

T :: Top;
L :: Left;
B :: Bottom;
R :: Right;


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

Move :: (using s: *Segment, delta: Vector2) {
    a += delta;
    b += delta;
}

ClosestPoint :: (a: Segment, b: Vector2) -> Vector2 {
    v0 := Vector(a);
    v1 := b - a.a;

    projection := dot(v1, v0) / length_squared(v0);
    Clamp(*projection, 0, 1);

    return a.b + v0 * projection;
}

ClosestPoint :: (a: Circle, b: Vector2) -> Vector2 {
    return ifx Colliding(a, b) then b else Center(a) + normalize(b - Center(a)) * a.r;
}

ClosestPoint :: (a: Rectangle, b: Vector2) -> Vector2 {
    x := clamp(b.x, L(a), R(a));
    y := clamp(b.y, T(a), B(a));
    return .{ x, y };
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

    r0 := clamp((d20 * d01 - d21 * d00) / (d00 * d11 - d01 * d01), 0, 1);
    r1 := clamp((d20 * d11 - d21 * d01) / (d00 * d11 - d01 * d01), 0, 1);

    parallel := Direction(a) == Direction(b) || Direction(a) == -Direction(b);
    if parallel {
        r0 = 0.0;
        r1 = clamp(d20 / d00, 0, 1);
    }

    ratio0 := clamp((r0 * d01 + d20) / d00, 0, 1);
    ratio1 := clamp((r1 * d01 - d21) / d11, 0, 1);

    point_on_a := a.a + v0 * ratio0;
    point_on_b := b.a + v1 * ratio1;

    return point_on_a, point_on_b;
}

Colliding :: (a: Vector2, b: Circle) -> bool #symmetric {
    dx := a.x - b.x;
    dy := a.y - b.y;
    return (dx * dx) + (dy * dy) <= (b.r * b.r);
}

Colliding :: (a: Vector2, b: Rectangle) -> bool #symmetric {
    return !(R(b) < a.x || a.x < L(b) || B(b) < a.y || a.y < T(b));
}

Colliding :: (a: Rectangle, b: Rectangle) -> bool {
    return !(R(a) < L(b) || R(b) < L(a) || B(a) < T(b) || B(b) < T(a));
}

Colliding :: (a: Circle, b: Circle) -> bool {
    dx := a.x - b.x;
    dy := a.y - b.y;
    return (dx * dx) + (dy * dy) <= (a.r + b.r) * (a.r + b.r);
}

Colliding :: (a: Circle, b: Rectangle) -> bool #symmetric {
    closest := ClosestPoint(b, Center(a));
    return Colliding(a, closest);
}

Colliding :: (a: Circle, b: Segment) -> bool #symmetric {
    closest := ClosestPoint(b, Center(a));
    return Colliding(a, closest);
}