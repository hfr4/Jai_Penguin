Particle_Emitter :: struct {
    texture: *Simp.Texture;

    position : Vector2;
    gravity  : Vector2;

    lifetime  := -1.0;
    elapsed   := 0.0;
    remainder := 0.0;

    producing := true;


    particles: [..] Particle;
    particles_per_second := 30;

    fadeout_period := 0.1;

    speed     := Vector2.{ 0.0 , 100.0 };
    size      := Vector2.{ 1.0 , 5.0   };
    drag      := Vector2.{ 0.99, 0.9   };
    _lifetime := Vector2.{ 0.4 , 1.0   };
    theta     := Vector2.{ 0.0 , TAU   };

    min_color := Vector4.{ 1, 1, 1, 1 };
    max_color := Vector4.{ 1, 1, 1, 1 };
}

Particle :: struct {
    position: Vector2;
    velocity: Vector2;
    color:    Vector4;
    size:     float;
    drag:     float;

    gravity: Vector2;

    lifetime: float;
    elapsed  := 0.0;
}

Deinit :: (emitter: *Particle_Emitter) {
    array_free(emitter.particles);
}

Update :: (emitter: *Particle_Emitter, dt: float) {
    for * p: emitter.particles {
        Update(p, dt);

        if p.elapsed > p.lifetime {
            remove p;
        }
    }

    emitter.elapsed   += dt;
    emitter.remainder += dt;

    if emitter.lifetime >= 0 then {
        emitter.lifetime -= dt;
        if emitter.lifetime < 0 then emitter.producing = false;
    }

    dt_per_particle := 1.0 / emitter.particles_per_second;

    if emitter.producing then {
        while emitter.remainder > dt_per_particle {
            emitter.remainder -= dt_per_particle;
            particle := SpawnParticle(emitter, emitter.position);
            Update(particle, emitter.remainder);
        }
    }
}

SpawnParticle :: (using emitter: *Particle_Emitter, pos: Vector2) -> *Particle {
    particle := array_add(*particles);

    particle.position = pos;
    particle.gravity  = gravity;

    spd := random_get_within_range(speed.x, speed.y);
    ang := random_get_within_range(theta.x, theta.y);
    particle.velocity = spd * Vector2.{ cos(ang), sin(ang) };

    particle.size     = lerp(size.x    , size.y    , random_get_within_range(0, 1));
    particle.drag     = lerp(drag.x    , drag.y    , random_get_within_range(0, 1));
    particle.lifetime = lerp(_lifetime.x, _lifetime.y, random_get_within_range(0, 1));
    particle.color    = lerp(min_color , max_color , random_get_within_range(0, 1));

    return particle;
}

Draw :: (emitter: Particle_Emitter) {
    transform := GetCurrentTransform();

    Simp.set_shader_for_images(emitter.texture);

    for * emitter.particles {
        alpha := 1.0;

        // Fade particle if it's time to do so.
        tail_time := it.lifetime - it.elapsed;
        if tail_time < emitter.fadeout_period {
            t := tail_time / emitter.fadeout_period;
            alpha = clamp(t, 0.0, 1.0);
        }

        color := it.color;
        color.w *= alpha;

        pos  := it.position;
        size := it.size * .5;

        x0 := pos.x - size;
        y0 := pos.y - size;
        x1 := pos.x + size;
        y1 := pos.y + size;

        p0 := TransformVertex(.{ x0, y0 }, transform);
        p1 := TransformVertex(.{ x1, y0 }, transform);
        p2 := TransformVertex(.{ x1, y1 }, transform);
        p3 := TransformVertex(.{ x0, y1 }, transform);

        Simp.immediate_quad(p0, p1, p2, p3, color);
    }
}

Update :: (using particle: *Particle, dt: float) {
    velocity -= gravity  * dt;
    position += velocity * dt;
    velocity *= drag;
    elapsed  += dt;
}