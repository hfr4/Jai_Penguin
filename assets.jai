PlaySound :: (sound: *Sound.Sound_Data) -> *Sound.Sound_Stream {
    stream := Sound.make_stream(sound, .GENERAL_SFX);
    Sound.start_playing(stream);
    return stream;
}

PlayMusic :: (sound: *Sound.Sound_Data) -> *Sound.Sound_Stream {
	stream := Sound.make_stream(sound, .MUSIC);
	Sound.set_repeating(stream, true);
	Sound.start_playing(stream);
    return stream;
}

GetTexture :: (name: string) -> *Simp.Texture {
    found := table_find_pointer(*textures, name);

    if !found {
        loaded: Simp.Texture;
        ok := Simp.texture_load_from_file(*loaded, tprint("./assets/textures/%.png", name));
        assert(ok);
        return table_add(*textures, name, loaded);
    }

    return found;
}

GetFont :: (name: string, size: int) -> *Simp.Dynamic_Font {
    found := table_find_pointer(*fonts, tprint("%_%", name, size));

    if !found then {
        loaded := Simp.get_font_at_size("./assets/fonts", tprint("%.ttf", name), size);
        assert(loaded != null);
        return table_add(*fonts, tprint("%_%", name, size), loaded).*;
    }

    return found.*;
}

GetSound :: (name: string) -> *Sound.Sound_Data {
    found := table_find_pointer(*sounds, name);

    if !found {
        loaded := Sound.load_audio_file(tprint("./assets/sounds/%.wav", name));
        assert(loaded.loaded);
        return table_add(*sounds, name, loaded);
    }

    return found;
}

GetMusic :: (name: string) -> *Sound.Sound_Data {
    found := table_find_pointer(*musics, name);

    if !found {
        loaded := Sound.load_audio_file(tprint("./assets/musics/%.ogg", name));
        assert(loaded.loaded);
        return table_add(*musics, name, loaded);
    }

    return found;
}

#scope_file

textures: Table(string, Simp.Texture);
fonts:    Table(string, *Simp.Dynamic_Font);
musics:   Table(string, Sound.Sound_Data);
sounds:   Table(string, Sound.Sound_Data);