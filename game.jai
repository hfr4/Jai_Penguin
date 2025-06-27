ResetGame :: () {
    penguin = .{
        state          = .LAUNCH,
        position       = .{ PENGUIN_X, PENGUIN_Y },
        radius         = PENGUIN_R,
        angle          = 0.0,
        velocity       = .{ 0.0, 0.0 },

        float_timer    = 0,
        bounce_timer   = 0,
        glide_stamina  = GLIDE_MAX_STAMINA,
        launch_charges = 0,

        is_floating    = false,
        is_bouncing    = false,
        is_gliding     = false,
    };

    power_indicator = .{ POWER_MIN, 1 };
    angle_indicator = .{ ANGLE_MIN, 1 };

    camera  = .{ 0.0, 0.0 };
    gravity = BASE_GRAVITY;

    score = 0;

    array_reset(*obstacles);
    array_reset(*powerups);
    array_reset(*background_objects);

    random_seed(cast(S128) current_time_consensus());

    GenerateObjects();
}

HandleGameInputs :: () {
    if Pressed(.ESCAPE) {
        QUIT_GAME = true;
    }

    if Pressed(.SPACEBAR) {
        if penguin.state == .LAUNCH || penguin.state == .RELAUNCH
        {
            if penguin.state == .RELAUNCH {
                penguin.launch_charges -= 1;
            }

            penguin.velocity.x =  power_indicator.value * cos(angle_indicator.value);
            penguin.velocity.y = -power_indicator.value * sin(angle_indicator.value);

            penguin.state = .FLYING;
        }
        else if penguin.state == .FLYING || penguin.state == .SLIDING
        {
            if penguin.glide_stamina > 0 {
                penguin.is_gliding = true;
            }
        }
    }

    if Pressed("R") {
        if penguin.state != .LANDED && penguin.state != .RELAUNCH && penguin.launch_charges > 0 {
            power_indicator.value     = POWER_MIN;
            power_indicator.direction = 1;

            angle_indicator.value     = ANGLE_MIN;
            angle_indicator.direction = 1;

            penguin.angle = 0;
            penguin.state = .RELAUNCH;
        }
    }

    if Pressed(.MOUSE_BUTTON_LEFT) {
        if penguin.state == .LANDED {
            center := Center(GameRectangle());
            half   := Vector2.{ 150, 50 };
            replay_rect := RectangleFromPoints(center - half, center + half);

            ok, mp := MousePositionOnGame();
            if ok && Colliding(mp, replay_rect) {
                ResetGame();
            }
        }
    }

    if Released(.SPACEBAR) {
        penguin.is_gliding = false;
    }
}

UpdateGame :: (dt: float) {
    // Float power up, don't update while relaunching
    if penguin.is_floating && penguin.state != .RELAUNCH {
        penguin.float_timer -= 1;
        if penguin.float_timer <= 0 {
            penguin.is_floating = false;
            gravity = BASE_GRAVITY;
        }
    }

    if penguin.is_bouncing {
        penguin.bounce_timer -= 1;
        if penguin.bounce_timer <= 0 {
            penguin.is_bouncing = false;
        }
    }

    // Activate glide when sliding
    if penguin.is_gliding && penguin.state == .SLIDING {
        penguin.velocity.y = -GLIDE_LIFT_POWER_FROM_GROUND;
        penguin.state = .FLYING;
    }

    if penguin.state == .LAUNCH || penguin.state == .RELAUNCH
    {
        power_indicator.value += POWER_SPEED * power_indicator.direction;
        if power_indicator.value < POWER_MIN || power_indicator.value > POWER_MAX {
            power_indicator.direction *= -1;
            Clamp(*power_indicator.value, POWER_MIN, POWER_MAX);
        }

        angle_indicator.value += ANGLE_SPEED * angle_indicator.direction;
        if angle_indicator.value < ANGLE_MIN || angle_indicator.value > ANGLE_MAX {
            angle_indicator.direction *= -1;
            Clamp(*angle_indicator.value, ANGLE_MIN, ANGLE_MAX);
        }
    }
    else if penguin.state == .FLYING
    {
        penguin.velocity.y += gravity;

        // Glide
        if penguin.is_gliding {
            penguin.velocity.y   -= GLIDE_LIFT_POWER;
            penguin.glide_stamina -= GLIDE_STAMINA_DEPLETION_RATE;

            if penguin.glide_stamina <= 0 {
                penguin.glide_stamina = 0;
                penguin.is_gliding    = false;
            }
        }

        penguin.position += penguin.velocity;
        penguin.angle = atan2(penguin.velocity.y, penguin.velocity.x);

        ResolveCollisions();

        if penguin.position.y + penguin.radius >= GROUND_Y {
            penguin.position.y = GROUND_Y - penguin.radius;

            if abs(penguin.velocity.y) > MIN_BOUNCE_VY {
                penguin.velocity.x *= (FRICTION + BOUNCE_DAMPING) / 2;
                penguin.velocity.y *= -BOUNCE_DAMPING;

                penguin.is_bouncing  = true;
                penguin.bounce_timer = BOUNCE_DURATION;
            } else {
                penguin.velocity.y = 0;
                if abs(penguin.velocity.x) > MIN_SLIDE_SPEED {
                    penguin.state = .SLIDING;
                } else {
                    penguin.velocity.x = 0;
                    penguin.state = .LANDED;
                }
            }
        }
    }
    else if penguin.state == .SLIDING
    {
        penguin.velocity.x *= FRICTION;
        penguin.position.x += penguin.velocity.x;

        penguin.angle += penguin.velocity.x * .05; // Roll

        ResolveCollisions();

        if abs(penguin.velocity.x) < MIN_SLIDE_SPEED {
            penguin.velocity.x = 0;
            penguin.state = .LANDED;
        }
    }

    // Camera
    if penguin.position.x > GAME_WIDTH / 2.0 {
        targetX := penguin.position.x - GAME_WIDTH / 2.5;
        camera.x += (targetX - camera.x) * 0.1;
    }

    // Score
    score = cast(int) max(0.0, floor((penguin.position.x - PENGUIN_X) / 10));
    if penguin.state == .LANDED {
        high_score = max(score, high_score);
    }
}

RenderGame :: () {
    Simp.set_render_target(*GAME, .LEFT_HANDED);
    Simp.clear_render_target(0, 0, 0, 1);

    // Background
    DrawRectangle(GameRectangle(), .{ 0.52, 0.80, 0.92, 1.0 });

    // Ground
    {
        r := Rectangle.{ 0, xx GROUND_Y, xx GAME_WIDTH, xx GROUND_H };
        DrawRectangle(r, .{ 1.0, 1.0, 1.0, 1.0 });
    }

    // Background objects
    {
        {
            PushTranslationThisScope(.{ -camera.x * .2, camera.y });
            for background_objects {
                if it.layer == .BACKGROUND {
                    if it.kind == .MOUNTAIN {
                        PushTranslationThisScope(.{ it.x, it.y });
                        DrawPolygonFill(.[ .{ 400, 0   }, .{ 0, -400 }, .{ -400, 0   } ] , Vector4.{ .2, .2, .4, 1.0} );
                        DrawPolygonFill(.[ .{ 50 ,-350 }, .{ 0, -400 }, .{ -50 ,-350 } ] , Vector4.{ .8, .8, .8, 1.0} );
                    }
                }
            }
        }

        {
            PushTranslationThisScope(.{ -camera.x * .6, camera.y });
            for background_objects {
                if it.layer == .MIDDLEGROUND {
                    if it.kind == .MOUNTAIN {
                        PushTranslationThisScope(.{ it.x, it.y });
                        DrawPolygonFill(.[ .{ 250 , 0 }, .{ 0 , -250 }, .{ -250, 0 } ], Vector4.{ .5, .5, .7, 1.0 } );
                    }
                }
            }
        }

        {
            PushTranslationThisScope(.{ -camera.x * .8, camera.y });
            for background_objects {
                if it.layer == .FOREGROUND {
                    if it.kind == .MOUNTAIN {
                        for background_objects {
                            PushTranslationThisScope(.{ it.x, it.y });
                            DrawPolygonFill(.[ .{ 100 , 0 }, .{ 0 , -100 }, .{ -100, 0 } ], Vector4.{ .8, .8, .9, 1.0} );
                        }
                    }
                }
            }
        }
    }

    {
        PushTranslationThisScope(-camera);

        for obstacles {
            if it.kind == {
                case .SNOWDRIFT;
                    DrawRectangle(it.rectangle, .{ 0.91, 0.96, 1.0, 1.0 });

                case .WALL;
                    DrawRectangle(it.rectangle, .{ 0.47, 0.66, 0.42, 1.0 });
            }
        }

        for powerups {
            if !it.active continue;

            if it.kind == {
                case .BOOST;
                    color := Vector4.{ 0.0, 0.8, 0.2, 1.0 };
                    DrawRectangle(it.rectangle, color);

                    arrow_head: [3] Vector2;
                    arrow_head[0] = Vector2.{ R(it.rectangle), CY(it.rectangle) } + Vector2.{ 0 , -20 };
                    arrow_head[1] = Vector2.{ R(it.rectangle), CY(it.rectangle) } + Vector2.{ 20,  0  };
                    arrow_head[2] = Vector2.{ R(it.rectangle), CY(it.rectangle) } + Vector2.{ 0 ,  20 };
                    DrawPolygonFill(arrow_head, color);

                case .FLOAT;
                    t : Transform;
                    t.translation = Center(it.circle);
                    t.rotation    = PI / 4.0;
                    PushTransformThisScope(t);

                    DrawEllipse(.{ 0.0, 0.0 }, it.circle.r * 0.7, it.circle.r, .{ 96 / 255.0, 165 / 255.0, 250 / 255.0, 1.0 });

                case .LAUNCH_CHARGE;
                    outer_radius := it.circle.r;
                    inner_radius := it.circle.r / 2.0;
                    angle        := PI / 2.0 * 3.0;

                    inner_vertices: [5] Vector2;
                    outer_vertices: [5] Vector2;

                    for i: 0..4 {
                        outer_vertices[i] = .{ it.rectangle.x + cos(angle) * outer_radius, it.rectangle.y + sin(angle) * outer_radius };
                        angle += PI / 5.0;

                        inner_vertices[i] = .{ it.rectangle.x + cos(angle) * inner_radius, it.rectangle.y + sin(angle) * inner_radius };
                        angle += PI / 5.0;
                    }

                    inner_color := Vector4.{ 250 / 255.0, 204 / 255.0, 21 / 255.0, 1.0 };
                    outer_color := Vector4.{ 161 / 255.0, 98  / 255.0, 7  / 255.0, 1.0 };

                    DrawPolygon(inner_vertices, inner_color);
                    DrawPolygon(.[ inner_vertices[4], outer_vertices[0], inner_vertices[0] ], inner_color);
                    DrawPolygon(.[ inner_vertices[0], outer_vertices[1], inner_vertices[1] ], inner_color);
                    DrawPolygon(.[ inner_vertices[1], outer_vertices[2], inner_vertices[2] ], inner_color);
                    DrawPolygon(.[ inner_vertices[2], outer_vertices[3], inner_vertices[3] ], inner_color);
                    DrawPolygon(.[ inner_vertices[3], outer_vertices[4], inner_vertices[4] ], inner_color);

                    DrawSegment(.{ outer_vertices[0], inner_vertices[0] }, outer_color, 2.0);
                    DrawSegment(.{ inner_vertices[0], outer_vertices[1] }, outer_color, 2.0);
                    DrawSegment(.{ outer_vertices[1], inner_vertices[1] }, outer_color, 2.0);
                    DrawSegment(.{ inner_vertices[1], outer_vertices[2] }, outer_color, 2.0);
                    DrawSegment(.{ outer_vertices[2], inner_vertices[2] }, outer_color, 2.0);
                    DrawSegment(.{ inner_vertices[2], outer_vertices[3] }, outer_color, 2.0);
                    DrawSegment(.{ outer_vertices[3], inner_vertices[3] }, outer_color, 2.0);
                    DrawSegment(.{ inner_vertices[3], outer_vertices[4] }, outer_color, 2.0);
                    DrawSegment(.{ outer_vertices[4], inner_vertices[4] }, outer_color, 2.0);
                    DrawSegment(.{ inner_vertices[4], outer_vertices[0] }, outer_color, 2.0);

                case .GLIDE_REFILL;
                    DrawCircle(it.circle, .{ 1.0, 0.0, 1.0, 1.0 });
            }
        }

        YETI_RECTANGLE :: Rectangle.{ 80, 340, 40, 60};

        // Yeti
        {
            // Body
            {
                DrawRectangle(YETI_RECTANGLE, .{ .54, .27, .07, 1.0 });
            }

            // Head
            {
                t : Transform;
                t.translation = .{ CX(YETI_RECTANGLE), YETI_RECTANGLE.y - 10 };
                t.rotation    = .4;
                PushTransformThisScope(t);

                DrawCircle(.{ 0, 0, YETI_RECTANGLE.w / 3 },  .{ .54, .27, .07, 1.0 });
                DrawCircle(.{ -5, 0, 2 }, WHITE);
                DrawCircle(.{  5, 0, 2 }, WHITE);
            }
        }

        // Indicators
        if penguin.state == .LAUNCH || penguin.state == .RELAUNCH {
            // Power bar
            {
                w : float = 15;
                h : float = 60;
                x : float = ifx penguin.state == .RELAUNCH then penguin.position.x - 45     else YETI_RECTANGLE.x - 30;
                y : float = ifx penguin.state == .RELAUNCH then penguin.position.y - h / 2  else YETI_RECTANGLE.y;

                percent := power_indicator.value / POWER_MAX;

                DrawRectangle(.{ x, y, w, h }                              , .{ 229 / 255.0, 231 / 255.0, 235 / 255.0, 1 });
                DrawRectangle(.{ x, y + (h - h * percent), w, h * percent }, .{ 239 / 255.0, 68  / 255.0, 68  / 255.0, 1 });
            }

            // Angle bar
            {
                s0 := SegmentFromPolar(penguin.position, angle_indicator.value, 20);
                s1 := SegmentFromPolar(penguin.position, angle_indicator.value, 50);

                DrawSegment(.{ s0.b, s1.b }, BLACK, 3);
            }
        }

        // Penguin
        DrawPenguin :: (pos: Vector2) {
            t : Transform;
            t.translation = pos;
            t.rotation    = penguin.angle;
            PushTransformThisScope(t);

            if penguin.is_floating {
                DrawCircle(.{ 0, 0, penguin.radius + 10 }, .{ 173 / 255.0, 216 / 255.0, 230 / 255.0, 0.7 });
            }

            DrawCircle(.{ 0, 0, penguin.radius }, BLACK);

            DrawEllipse(.{ 0, 0 }, penguin.radius - 5, penguin.radius - 3, WHITE);

            DrawSegment(Segment.{ .{ 5, 1 }, .{ 20, 1 } }, ORANGE, 3);

            // Eyes
            if penguin.is_bouncing {
                l0 := Segment.{ .{ -6, -7 }, .{ -2,  0 } };
                l1 := Segment.{ .{ -6,  0 }, .{ -2, -7 } };
                DrawSegment(l0, BLACK, 2.0);
                DrawSegment(l1, BLACK, 2.0);

                r0 := Segment.{ .{ 2, -7 }, .{ 6,  0 } };
                r1 := Segment.{ .{ 2,  0 }, .{ 6, -7 } };
                DrawSegment(r0, BLACK, 2.0);
                DrawSegment(r1, BLACK, 2.0);

            } else if penguin.is_gliding {
                l := Segment.{ .{ -8, -4 }, .{ -2, -4 } };
                r := Segment.{ .{  2, -4 }, .{  8, -4 } };
                DrawSegment(l, BLACK, 2.0);
                DrawSegment(r, BLACK, 2.0);
            } else {
                DrawCircle(.{ -5, -4 , 2 }, BLACK);
                DrawCircle(.{  5, -4 , 2 }, BLACK);
            }

            // Wings
            if penguin.is_gliding {
                a := Vector2.{ -7, 3 };
                b := Vector2.{  3, 3 };
                c := Vector2.{ - 2, cast(float) sin(seconds_since_init() * 20.0) * 15.0 };

                DrawPolygonFill(.[ a, b, c ], WHITE);
                DrawPolygonLine(.[ a, b, c ], BLACK, 2.0);
            }
        }

        DrawPenguin(penguin.position);

        // Out of bound penguin indicator
        if penguin.position.y < -penguin.radius {
            DrawPolygon(.[ .{ penguin.position.x - 15, 20 }, .{ penguin.position.x + 15, 20 }, .{ penguin.position.x, 5 }]);
            DrawCircle(.{ penguin.position.x, 55, 30 });
            DrawPenguin(.{ penguin.position.x, 55 });
        }
    }

    // Ui
    {
        // Glide stamina
        {
            percent := (penguin.glide_stamina / GLIDE_MAX_STAMINA);

            w : float = 500;
            h : float = 25;
            x : float = (GAME_WIDTH / 2) - (w / 2);
            y : float = GROUND_Y + (GROUND_H / 2) - (h / 2);

            DrawRectangle(.{ x, y, w          , h }, .{ 0, 0, 0, 1 });
            DrawRectangle(.{ x, y, w * percent, h }, .{ 1, 0, 0, 1 });
        }

        // Replay screen
        if penguin.state == .LANDED {
            DrawRectangle(GameRectangle(), .{ 0, 0, 0, .6 });

            center      := Center(GameRectangle());
            half        := Vector2.{ 150, 50 };
            replay_rect := RectangleFromPoints(center - half, center + half);

            ok, mp := MousePositionOnGame();
            color := ifx ok && Colliding(mp, replay_rect) then RED else WHITE;

            {
                PushTranslationThisScope(Center(GameRectangle()));
                DrawCenteredText(GetFont("default", 48), "Replay ?", .{ -5.0, -5.0 }, RED);
                DrawCenteredText(GetFont("default", 48), "Replay ?", .{  0.0,  0.0 }, color);
            }
        }

        // Score
        {
            color := ifx penguin.state == .LANDED then WHITE else BLACK;

            {
                PushTranslationThisScope(.{ 10, 24 });
                DrawText(GetFont("default", 24), tprint("Score : %", score), .{ -2.0, -2.0 }, RED  , .TOP, .LEFT);
                DrawText(GetFont("default", 24), tprint("Score : %", score), .{  0.0,  0.0 }, color, .TOP, .LEFT);
            }

            {
                PushTranslationThisScope(.{ GameRectangle().w - 10, 24 });
                DrawText(GetFont("default", 24), tprint("HiScore : %", high_score), .{ -2.0, -2.0 }, RED  , .TOP, .RIGHT);
                DrawText(GetFont("default", 24), tprint("HiScore : %", high_score), .{  0.0,  0.0 }, color, .TOP, .RIGHT);
            }
        }

        // Relaunch button
        if penguin.launch_charges > 0 {
            h : float = 25;
            y : float = GROUND_Y + (GROUND_H / 2) - (h / 2);
            w : float = 100;
            x : float = GAME_WIDTH - w - 20;

            r := Rectangle.{ x, y, w, h };

            DrawRectangle(r, .{ 1, 1, 0, 1 });
            DrawCenteredText(GetFont("default", 16), tprint("Relaunch x%", penguin.launch_charges), Center(r), BLACK);
        }
    }
}

GenerateObjects :: () {
    rng :: random_get_zero_to_one;

    // PowerUps
    {
        obj_count   := 35;
        min_spacing := 380;
        max_spacing := 800;

        for i: 0..obj_count - 1 {
            x := PENGUIN_X + 700 + i * (min_spacing + rng() * (max_spacing - min_spacing));

            roll := rng();
            if      roll < 1/4.0  array_add(*powerups, .{ kind = .BOOST        , rectangle = .{ x, GROUND_Y - (30 + rng() * 120), 50, 20 }         , active = true });
            else if roll < 2/4.0  array_add(*powerups, .{ kind = .FLOAT        , circle    = .{ x + rng() * 20, GROUND_Y - (50 + rng() * 100), 15 }, active = true });
            else if roll < 3/4.0  array_add(*powerups, .{ kind = .LAUNCH_CHARGE, circle    = .{ x + rng() * 20, GROUND_Y - (40 + rng() * 90) , 18 }, active = true });
            else                  array_add(*powerups, .{ kind = .GLIDE_REFILL , circle    = .{ x + rng() * 20, GROUND_Y - (30 + rng() * 120), 16 }, active = true });
        }
    }

    // Obstacles
    {
        obj_count   := 70;
        min_spacing := 500;
        max_spacing := 1000;

        for i: 0..obj_count - 1 {
            x := PENGUIN_X + 700 + i * (min_spacing + rng()  * (max_spacing - min_spacing));

            roll := rng();
            if roll < 1.5/2.0 array_add(*obstacles, .{ kind = .WALL      , rectangle = .{ x, GROUND_Y - (20 + rng() * 80), 20 + rng()  * 30, 40 + rng()  * 100 } });
            else              array_add(*obstacles, .{ kind = .SNOWDRIFT , rectangle = .{ x, GROUND_Y - (10 + rng() * 20), 80 + rng()  * 70, 20 + rng()  * 30  } });
        }
    }

    // Background objects
    {
        obj_count := 35;

        for i: 0..obj_count - 1 {
            min_spacing := 800;
            max_spacing := 2000;
            x := PENGUIN_X + 700 + i * (min_spacing + rng()  * (max_spacing - min_spacing));
            array_add(*background_objects, .{ .BACKGROUND, .MOUNTAIN, .{ x + rng() * 20, GROUND_Y } });
        }

        for i: 0..obj_count - 1 {
            min_spacing := 800;
            max_spacing := 2000;
            x := PENGUIN_X + 700 + i * (min_spacing + rng()  * (max_spacing - min_spacing));
            array_add(*background_objects, .{ .MIDDLEGROUND, .MOUNTAIN, .{ x + rng() * 20, GROUND_Y } });
        }

        for i: 0..obj_count - 1 {
            min_spacing := 500;
            max_spacing := 1000;
            x := PENGUIN_X + 700 + i * (min_spacing + rng()  * (max_spacing - min_spacing));
            array_add(*background_objects, .{ .FOREGROUND, .MOUNTAIN, .{ x + rng() * 20, GROUND_Y } });
        }
    }
}

ResolveCollisions :: () {
    penguin_circ := Circle.{ penguin.position.x, penguin.position.y, penguin.radius };

    for obstacles {
        if Colliding(penguin_circ, it.rectangle) {
            if it.kind == {
                case .WALL;
                    overlapX := (penguin.radius + it.rectangle.w / 2) - abs(penguin.position.x - CX(it.rectangle));
                    overlapY := (penguin.radius + it.rectangle.h / 2) - abs(penguin.position.y - CY(it.rectangle));

                    if overlapX < overlapY {
                        penguin.velocity.x *= -0.5;
                        penguin.position.x = ifx penguin.position.x < CX(it.rectangle) then L(it.rectangle) - penguin.radius - 1 else R(it.rectangle) + penguin.radius + 1;
                    } else {
                        penguin.velocity.y *= -0.5;
                        penguin.position.y = ifx penguin.position.y < CY(it.rectangle) then T(it.rectangle) - penguin.radius - 1 else B(it.rectangle) + penguin.radius + 1;
                    }

                    penguin.is_bouncing  = true;
                    penguin.bounce_timer = BOUNCE_DURATION;

                case .SNOWDRIFT;
                    penguin.velocity.x *= 0.85;
                    if abs(penguin.velocity.y) > 0.1 penguin.velocity.y *= 0.9;
            }
        }
    }

    for * powerups {
        if !it.active continue;

        collided := false;
        if it.kind == .BOOST {
            if Colliding(penguin_circ, it.rectangle) collided = true;
        } else {
            if Colliding(penguin_circ, it.circle)    collided = true;
        }

        if collided {
            it.active = false;

            if it.kind == {
                case .BOOST;
                    penguin.velocity.x += BOOST_VALUE;
                    if penguin.velocity.y < 0 penguin.velocity.y -= BOOST_VALUE / 3;

                case .FLOAT;
                    penguin.is_floating = true;
                    penguin.float_timer = FLOAT_DURATION;
                    gravity            = BASE_GRAVITY * FLOAT_GRAVITY_MULTIPLIER;

                case .LAUNCH_CHARGE;
                    penguin.launch_charges += 1;

                case .GLIDE_REFILL;
                    penguin.glide_stamina = min(GLIDE_MAX_STAMINA, penguin.glide_stamina + GLIDE_REFILL_AMOUNT);
            }
        }
    }
}

penguin: struct {
    State :: enum {
        LAUNCH;
        RELAUNCH;
        FLYING;
        SLIDING;
        LANDED;
    }
    state: State;

    position:       Vector2;
    radius:         float;
    angle:          float;
    velocity:       Vector2;

    float_timer:    int;
    bounce_timer:   int;
    glide_stamina:  float;
    launch_charges: int;

    is_floating:    bool;
    is_bouncing:    bool;
    is_gliding:     bool;
}

power_indicator: struct {
    value:     float;
    direction: int;
}

angle_indicator: struct {
    value:     float;
    direction: int;
}

obstacles:          [..] Obstacle;
powerups:           [..] Power_Up;
background_objects: [..] Background_Object;

camera: Vector2;

gravity: float;

score:      int;
high_score: int;

GROUND_H     :: 50;
GROUND_Y     :: 400;

PENGUIN_X    :: 140;
PENGUIN_Y    :: 385;
PENGUIN_R    :: 15;

BASE_GRAVITY :: 0.25;

POWER_MIN    :: 10.0;
POWER_MAX    :: 25.0;
POWER_SPEED  :: 0.4;

ANGLE_MIN    :: 5  * (PI / 180);
ANGLE_MAX    :: 80 * (PI / 180);
ANGLE_SPEED  :: 1  * (PI / 180);

FRICTION        :: 0.985;
BOUNCE_DAMPING  :: 0.6;
MIN_SLIDE_SPEED :: 0.1;
MIN_BOUNCE_VY   :: 1.0;

FLOAT_DURATION           :: 180;
FLOAT_GRAVITY_MULTIPLIER :: 0.3;

BOUNCE_DURATION :: 15;

BOOST_VALUE :: 8;

GLIDE_MAX_STAMINA            :: 100.0;
GLIDE_STAMINA_DEPLETION_RATE :: 0.75;
GLIDE_LIFT_POWER             :: 0.4;
GLIDE_LIFT_POWER_FROM_GROUND :: 3.5;
GLIDE_REFILL_AMOUNT          :: 50;

Power_Up :: struct {
    Kind :: enum {
        BOOST;
        FLOAT;
        LAUNCH_CHARGE;
        GLIDE_REFILL;
    }
    kind: Kind;

    using collider: union {
        rectangle : Rectangle;
        circle :    Circle;
    }

    active: bool;
}

Obstacle :: struct {
    Kind :: enum {
        WALL;
        SNOWDRIFT;
    }
    kind: Kind;

    using collider : union {
        rectangle: Rectangle;
        circle:    Circle;
    }
}

Background_Object :: struct {
    Layer :: enum {
        FOREGROUND;
        MIDDLEGROUND;
        BACKGROUND;
    }

    Kind :: enum {
        MOUNTAIN;
    }

    layer: Layer;
    kind:  Kind;
    using position: Vector2;
}
