main :: () {
    WINDOW = Window.create_window(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE);
    Simp.set_render_target(WINDOW);

    GAME = Simp.texture_create_render_target(GAME_WIDTH, GAME_HEIGHT, .RGBA8);

    assert(Sound.sound_player_init(.{}));
    defer Sound.sound_player_shutdown();

    ResetGame();

    time_accumulator: float64;
    last_time := seconds_since_init();

    while !QUIT_GAME {
        now := seconds_since_init();
        dt  := now - last_time;
        last_time = now;

        Input.update_window_events();

        for Input.get_window_resizes() {
            Simp.update_window(it.window);

            if it.window == WINDOW {
                WINDOW_WIDTH  = it.width;
                WINDOW_HEIGHT = it.height;
            }
        }

        for Input.events_this_frame {
            if it.type == .QUIT QUIT_GAME = true;
        }

        HandleGameInputs();

        time_accumulator += min(dt, 0.25);
        while time_accumulator >= TIME_STEP {
            UpdateGame(TIME_STEP);
            time_accumulator -= TIME_STEP;
        }

        Sound.update();

        RenderGame();

        Simp.set_render_target(WINDOW, .LEFT_HANDED);
        Simp.clear_render_target(0, 0, 0, 1);

        Simp.set_shader_for_images(*GAME);
        tl := Center(WindowRectangle()) - Center(GameRectangle()) * AspectRatio();
        br := Center(WindowRectangle()) + Center(GameRectangle()) * AspectRatio();
        Simp.immediate_quad(tl.x, tl.y, br.x, br.y, WHITE);

        Simp.swap_buffers(WINDOW);

        reset_temporary_storage();
        sleep_milliseconds(10);
    }
}

WindowRectangle :: () -> Rectangle {
    r: Rectangle;
    r.w = cast(float) WINDOW_WIDTH;
    r.h = cast(float) WINDOW_HEIGHT;
    return r;
}

GameRectangle :: () -> Rectangle {
    r: Rectangle;
    r.w = cast(float) GAME_WIDTH;
    r.h = cast(float) GAME_HEIGHT;
    return r;
}

AspectRatio :: () -> float {
    ratio := Size(WindowRectangle()) / Size(GameRectangle());
	return min(ratio.x, ratio.y);
}

WindowToGame :: (position: Vector2) -> Vector2 {
    on_game := position;
	on_game -= Center(WindowRectangle()) - Size(GameRectangle()) * AspectRatio() / 2.0;
	on_game /= AspectRatio();
	return on_game;
}

GameToWindow :: (position: Vector2) -> Vector2 {
    on_window := position;
    on_window *= AspectRatio();
    on_window += Center(WindowRectangle()) - Size(GameRectangle()) * AspectRatio() / 2.0;
    return on_window;
}

MousePositionOnWindow :: () -> bool, Vector2 {
	x, y, ok := Window.get_mouse_pointer_position(right_handed = false);
	return ok, .{ cast(float) x, cast(float) y };
}

MousePositionOnGame :: () -> bool, Vector2 {
	ok, on_window := MousePositionOnWindow();
	if !ok return false, .{};
    on_game := WindowToGame(on_window);
	return true, .{ cast(float) (cast(int) on_game.x), cast(float) (cast(int) on_game.y) };
}

Pressed :: (keycode: Input.Key_Code) -> bool {
    return cast(bool) (Input.input_button_states[keycode] & .START);
}

Pressed :: (keycode: u8) -> bool {
    return cast(bool) (Input.input_button_states[xx keycode] & .START);
}

Released :: (keycode: Input.Key_Code) -> bool {
    return cast(bool) (Input.input_button_states[keycode] & .END);
}

Released :: (keycode: u8) -> bool {
    return cast(bool) (Input.input_button_states[xx keycode] & .END);
}

Down :: (keycode: Input.Key_Code) -> bool {
    return cast(bool) (Input.input_button_states[keycode] & .DOWN);
}

Down :: (keycode: u8) -> bool {
    return cast(bool) (Input.input_button_states[xx keycode] & .DOWN);
}

WINDOW        : Window.Window_Type;
WINDOW_WIDTH  : s32 = 1200;
WINDOW_HEIGHT : s32 = 675;

WINDOW_TITLE := "Penguin";

GAME        : Simp.Texture;
GAME_WIDTH  : s32 = 1200;
GAME_HEIGHT : s32 = 450;

QUIT_GAME := false;
TIME_STEP := 1 / 60.0;

#load "game.jai";
#load "assets.jai";
#load "tween.jai";
#load "draw.jai";
#load "animation.jai";
#load "rectangle.jai";
#load "circle.jai";
#load "segment.jai";

#import "Basic";
#import "Math";
#import "String";
#import "Hash_Table";
#import "Random";
#import "Sort";

Window :: #import "Window_Creation";
GL     :: #import "GL";
Input  :: #import "Input";
Simp   :: #import "Simp";
Sound  :: #import "Sound_Player";