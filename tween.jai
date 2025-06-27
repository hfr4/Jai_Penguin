Tween :: (pointer: *$T, start: T, end: T, percent: float, fn: (x: float) -> float) {
   pointer.* = start + (end - start) * fn(percent);
}

tween :: (start: $T, end: T, percent: float, fn: (x: float) -> float) -> T {
    return start + (end - start) * fn(percent);
}

Linear :: (x: float) -> float {
    return x;
}

InQuad :: (x: float) -> float {
    return x * x;
}

InCubic :: (x: float) -> float {
    return x * x * x;
}

InQuart :: (x: float) -> float {
    return x * x * x * x;
}

InQuint :: (x: float) -> float {
    return x * x * x * x * x;
}

InSine :: (x: float) -> float {
    return 1.0 - sin((1.0 - x) * HALF_PI);
}

InCirc :: (x: float) -> float {
    return 1.0 - sqrt(1.0 - x * x);
}

InExpo :: (x: float) -> float {
    return pow(2.0, 10.0 * (x - 1.0));
}

InBack :: (x: float) -> float {
    return x * x * ((1.0 + HALF_PI) * x - HALF_PI);
}

InElastic :: (x: float) -> float {
    return sin(13.0 * x * HALF_PI) * pow(2.0, 10.0 * (x - 1.0));
}

InBounce :: (x: float) -> float {
    if      x < 0.09090 return 0.01563 - 7.5625 * pow(0.04545 - x, 2.0);
    else if x < 0.27272 return 0.06250 - 7.5625 * pow(0.18181 - x, 2.0);
    else if x < 0.63636 return 0.25000 - 7.5625 * pow(0.45454 - x, 2.0);
    else                return 1.00000 - 7.5625 * pow(1.00000 - x, 2.0);
}

OutQuad :: (x: float) -> float {
    return 1.0 - InQuad(1.0 - x);
}

OutCubic :: (x: float) -> float {
    return 1.0 - InCubic(1.0 - x);
}

OutQuart :: (x: float) -> float {
    return 1.0 - InQuart(1.0 - x);
}

OutQuint :: (x: float) -> float {
    return 1.0 - InQuint(1.0 - x);
}

OutSine :: (x: float) -> float {
    return 1.0 - InSine(1.0 - x);
}

OutCirc :: (x: float) -> float {
    return 1.0 - InCirc(1.0 - x);
}

OutExpo :: (x: float) -> float {
    return 1.0 - InExpo(1.0 - x);
}

OutBack :: (x: float) -> float {
    return 1.0 - InBack(1.0 - x);
}

OutElastic :: (x: float) -> float {
    return 1.0 - InElastic(1.0 - x);
}

OutBounce :: (x: float) -> float {
    return 1.0 - InBounce(1.0 - x);
}

InOutQuad :: (x: float) -> float {
    return 0.5 * (ifx x < 0.5 then InQuad(x * 2.0) else 1.0 + OutQuad(x * 2.0 - 1.0));
}

InOutCubic :: (x: float) -> float {
    return 0.5 * (ifx x < 0.5 then InCubic(x * 2.0) else 1.0 + OutCubic(x * 2.0 - 1.0));
}

InOutQuart :: (x: float) -> float {
    return 0.5 * (ifx x < 0.5 then InQuart(x * 2.0) else 1.0 + OutQuart(x * 2.0 - 1.0));
}

InOutQuint :: (x: float) -> float {
    return 0.5 * (ifx x < 0.5 then InQuint(x * 2.0) else 1.0 + OutQuint(x * 2.0 - 1.0));
}

InOutSine :: (x: float) -> float {
    return 0.5 * (ifx x < 0.5 then InSine(x * 2.0) else 1.0 + OutSine(x * 2.0 - 1.0));
}

InOutCirc :: (x: float) -> float {
    return 0.5 * (ifx x < 0.5 then InCirc(x * 2.0) else 1.0 + OutCirc(x * 2.0 - 1.0));
}

InOutExpo :: (x: float) -> float {
    return 0.5 * (ifx x < 0.5 then InExpo(x * 2.0) else 1.0 + OutExpo(x * 2.0 - 1.0));
}

InOutBack :: (x: float) -> float {
    return 0.5 * (ifx x < 0.5 then InBack(x * 2.0) else 1.0 + OutBack(x * 2.0 - 1.0));
}

InOutElastic :: (x: float) -> float {
    return 0.5 * (ifx x < 0.5 then InElastic(x * 2.0) else 1.0 + OutElastic(x * 2.0 - 1.0));
}

InOutBounce :: (x: float) -> float {
    return 0.5 * (ifx x < 0.5 then InBounce(x * 2.0) else 1.0 + OutBounce(x * 2.0 - 1.0));
}

#scope_file

HALF_PI :: PI / 2.0;
