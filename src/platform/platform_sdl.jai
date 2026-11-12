platform_init :: (title: string, width: s32, height: s32) -> Window, bool
{
    SDL_SetAppMetadata("cutengine", "v0.0.1", "com.engine.cutengine");

    ok := SDL_InitSubSystem(SDL_INIT_VIDEO);
    if !ok {
        log_error("Couldn't initialize SDL: %", SDL_GetErrorString());
        return .{}, false;
    }

    // Use high pixel density, otherwise we have blurry edges on MacOS
    window_flags: SDL_WindowFlags = SDL_WINDOW_HIGH_PIXEL_DENSITY | SDL_WINDOW_RESIZABLE;
    sdl_window := SDL_CreateWindow(to_c_string(title,,temp), width, height, window_flags);
    if !sdl_window {
        log_error("Couldn't create SDL window: %", SDL_GetErrorString());
        return .{}, false;
    }

    window: Window;
    window.native = cast(*Native_Window) sdl_window;
    window.width = width;
    window.height = height;
    return window, true;
}

platform_shutdown :: (window: *Window)
{
    sdl_win := convert_to_sdl_window(window);
    SDL_DestroyWindow(sdl_win);
    SDL_Quit();
}

platform_poll_events :: (window: *Window, input: *Input)
{
    event: SDL_Event;
    while SDL_PollEvent(*event) {
	    if cast(SDL_EventType) event.type == {
		case .SDL_EVENT_QUIT;
		    input.quit_requested = true;

        // Keyboard-related events
		case .SDL_EVENT_KEY_DOWN; #through;
        case .SDL_EVENT_KEY_UP;
            if event.key.repeat  continue;
            key := translate_sdl_key(event.key.scancode);
            if key == .UNKNOWN  continue;

            b := *input.keyboard_buttons[key];
            b.ended_down = cast(SDL_EventType) event.type == .SDL_EVENT_KEY_DOWN;
            b.half_transitions += 1;

        // Mouse-related events
        case .SDL_EVENT_MOUSE_BUTTON_DOWN; #through;
        case .SDL_EVENT_MOUSE_BUTTON_UP;
            button := translate_sdl_mouse_button(event.button.button);
            b := *input.mouse_buttons[button];
            b.ended_down = cast(SDL_EventType)event.type == .SDL_EVENT_MOUSE_BUTTON_DOWN;
            b.half_transitions += 1;
        case .SDL_EVENT_MOUSE_WHEEL;
            input.mouse_scroll_wheel += event.wheel.y;
        case .SDL_EVENT_MOUSE_MOTION;
            input.mouse_pos.x = event.motion.x;
            input.mouse_pos.y = event.motion.y;
            input.mouse_delta.x += event.motion.xrel;
            input.mouse_delta.y += event.motion.yrel;
	    }
	}
}

platform_get_window_width :: (window: *Window) -> (u32, u32)
{
    window_width, window_height: s32;
    SDL_GetWindowSizeInPixels(convert_to_sdl_window(window), *window_width, *window_height);
    return cast(u32) window_width, cast(u32) window_height;
}

#scope_file

convert_to_sdl_window :: inline (w: *Window) -> *SDL_Window
{
    return cast(*SDL_Window) w.native;
}

translate_sdl_mouse_button :: (sdl_button: u8) -> Mouse_Button
{
    if sdl_button == {
        case SDL_BUTTON_LEFT;   return .LEFT_CLICK;
        case SDL_BUTTON_RIGHT;  return .RIGHT_CLICK;
        case SDL_BUTTON_MIDDLE; return .SCROLL_WHEEL_CLICK;
    }

    return .UNKNOWN;
}

translate_sdl_key :: (sdl_key: SDL_Scancode) -> Keyboard_Key
{
    SDL :: SDL_Scancode; MY :: Keyboard_Key;

    if sdl_key == {
        case SDL_SCANCODE_Q; return MY.Q;
        case SDL_SCANCODE_W; return MY.W;
        case SDL_SCANCODE_E; return MY.E;
        case SDL_SCANCODE_R; return MY.R;
        case SDL_SCANCODE_T; return MY.T;
        case SDL_SCANCODE_Y; return MY.Y;
        case SDL_SCANCODE_U; return MY.U;
        case SDL_SCANCODE_I; return MY.I;
        case SDL_SCANCODE_O; return MY.O;
        case SDL_SCANCODE_P; return MY.P;

        case SDL_SCANCODE_A; return MY.A;
        case SDL_SCANCODE_S; return MY.S;
        case SDL_SCANCODE_D; return MY.D;
        case SDL_SCANCODE_F; return MY.F;
        case SDL_SCANCODE_G; return MY.G;
        case SDL_SCANCODE_H; return MY.H;
        case SDL_SCANCODE_J; return MY.J;
        case SDL_SCANCODE_K; return MY.K;
        case SDL_SCANCODE_L; return MY.L;

        case SDL_SCANCODE_Z; return MY.Z;
        case SDL_SCANCODE_X; return MY.X;
        case SDL_SCANCODE_C; return MY.C;
        case SDL_SCANCODE_V; return MY.V;
        case SDL_SCANCODE_B; return MY.B;
        case SDL_SCANCODE_N; return MY.N;
        case SDL_SCANCODE_M; return MY.M;

        case SDL_SCANCODE_1; return MY.NUM_1;
        case SDL_SCANCODE_2; return MY.NUM_2;
        case SDL_SCANCODE_3; return MY.NUM_3;
        case SDL_SCANCODE_4; return MY.NUM_4;
        case SDL_SCANCODE_5; return MY.NUM_5;
        case SDL_SCANCODE_6; return MY.NUM_6;
        case SDL_SCANCODE_7; return MY.NUM_7;
        case SDL_SCANCODE_8; return MY.NUM_8;
        case SDL_SCANCODE_9; return MY.NUM_9;
        case SDL_SCANCODE_0; return MY.NUM_0;

        case SDL_SCANCODE_LEFT;  return MY.LEFT_ARROW;
        case SDL_SCANCODE_RIGHT; return MY.RIGHT_ARROW;
        case SDL_SCANCODE_UP;    return MY.UP_ARROW;
        case SDL_SCANCODE_DOWN;  return MY.DOWN_ARROW;

        case SDL_SCANCODE_MINUS;        return MY.MINUS;
        case SDL_SCANCODE_EQUALS;       return MY.EQUALS;
        case SDL_SCANCODE_LEFTBRACKET;  return MY.LEFT_BRACKET;
        case SDL_SCANCODE_RIGHTBRACKET; return MY.RIGHT_BRACKET;
        case SDL_SCANCODE_BACKSLASH;    return MY.BACKSLASH;
        case SDL_SCANCODE_SEMICOLON;    return MY.SEMICOLON;
        case SDL_SCANCODE_APOSTROPHE;   return MY.TICK;
        case SDL_SCANCODE_COMMA;        return MY.COMMA;
        case SDL_SCANCODE_PERIOD;       return MY.DOT;
        case SDL_SCANCODE_SLASH;        return MY.SLASH;
        case SDL_SCANCODE_GRAVE;        return MY.BACKTICK;

        case SDL_SCANCODE_LSHIFT; return MY.LEFT_SHIFT;
        case SDL_SCANCODE_RSHIFT; return MY.RIGHT_SHIFT;
        case SDL_SCANCODE_LCTRL;  return MY.LEFT_CTRL;
        case SDL_SCANCODE_RCTRL;  return MY.RIGHT_CTRL;
        case SDL_SCANCODE_LALT;   return MY.LEFT_ALT;    // Option on Mac
        case SDL_SCANCODE_RALT;   return MY.RIGHT_ALT;
        case SDL_SCANCODE_LGUI;   return MY.LEFT_CMD;    // Cmd on Mac, Windows key on PC
        case SDL_SCANCODE_RGUI;   return MY.RIGHT_CMD;   // Mac only

        case SDL_SCANCODE_RETURN; return MY.RETURN;
        case SDL_SCANCODE_DELETE; return MY.DELETE;
        case SDL_SCANCODE_ESCAPE; return MY.ESCAPE;
    }

    return .UNKNOWN;
}

#import "Extensions/SDL3";