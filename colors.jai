WHITE  :: Vector4.{ 1., 1., 1., 1. };
BLACK  :: Vector4.{ 0., 0., 0., 1. };
RED    :: Vector4.{ .9, .1, .2, 1. };
GREEN  :: Vector4.{ 0., .8, .1, 1. };
BLUE   :: Vector4.{ 0., .4, .9, 1. };
YELLOW :: Vector4.{ .9, .9, 0., 1. };
PINK   :: Vector4.{ 1., .4, .7, 1. };
ORANGE :: Vector4.{ 1., .6, 0., 1. };
BROWN  :: Vector4.{ .4, .4, .3, 1. };
CYAN   :: Vector4.{ 0., 1., 1., 1. };

HexToRgba :: (hex: int) -> Vector4 {
    assert(hex >= 0x00000000 && hex <= 0xFFFFFFFF);

    r, g, b, a: int;

    if hex <= 0xFFFFFF {
        r = (hex >> 16) & 0xFF;
        g = (hex >> 08) & 0xFF;
        b = hex         & 0xFF;
        a = 255;
    } else {
        r = (hex >> 24) & 0xFF;
        g = (hex >> 16) & 0xFF;
        b = (hex >> 08) & 0xFF;
        a = hex         & 0xFF;
    }

    return .{ r / 255.0, g / 255.0, b / 255.0, a / 255.0 };
}
