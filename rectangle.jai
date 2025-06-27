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

ClosestPoint :: (a: Vector2, b: Rectangle) -> Vector2 {
    x := clamp(a.x, L(b), R(b));
    y := clamp(a.y, L(b), R(b));
    return .{ x, y };
}

Colliding :: (a: Vector2, b: Rectangle) -> bool #symmetric {
    return !( R(b) < a.x || a.x < L(b) || B(b) < a.y || a.y < T(b) );
}

Colliding :: (a: Rectangle, b: Rectangle) -> bool {
    return !( R(a) < L(b) || R(b) < L(a) || B(a) < T(b) || B(b) < T(a) );
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
