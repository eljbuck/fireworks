// willow_new_new.ck
global Event barrage_boom;
global Event reset_signal;

public class Barrage extends GGen {
    14 => int NUM_SHELLS;
    30 => int TRAIL_LENGTH;
    Particle shells[NUM_SHELLS];
    TrailPool trail_pool[NUM_SHELLS];
    FlatMaterial trail_mat[NUM_SHELLS];
    for (0 => int i; i < NUM_SHELLS; 1 +=> i) {
        trail_mat[i].color(@(1, 1, 1));
        trail_pool[i].init(TRAIL_LENGTH, NUM_SHELLS, 0.15, trail_mat[i]);
    }
    // trail_mat.color(@(1, 1, 1));
    // trail_pool.init(TRAIL_LENGTH, NUM_SHELLS, 0.15, trail_mat);
    // trail_pool.size() => int initial_size;
    @(0, -0.015, 0) => vec3 gravity;
    200::ms => dur del;
    vec3 initial_pos;

    fun void init(vec3 c) {
        for (0 => int i; i < NUM_SHELLS; 1 +=> i) {
            FlatMaterial shell_mat;
            shell_mat.color(c);
            shells[i] --> this;
            shells[i].init(gravity, shell_mat, trail_pool[i], 200::ms, 6, 1);
        }
        shells[0].get_pos_world() => initial_pos;
    }

    fun vec3 get_vel(vec3 vel) {
        vel.y => float v;
        Math.random2f(Math.pi / 2, Math.pi / 2 + 0.05) => float theta;
        v * Math.sin((Math.pi / 2) - theta) => float x;
        if (Math.random2(0, 1)) {
            -1 *=> x;
        }
        v * Math.cos((Math.pi / 2) - theta) => float y;
        return @(x, y, 0);
    }

    fun void launch(vec3 vel) {
        <<< "launch" >>>;
        // <<< "trail_pool initial size:",  initial_size >>>;
        // <<< "trail_pool size:", trail_pool.size() >>>;
        // <<< "trail_pool active size:", trail_pool.active_size() >>>;
        barrage_boom.broadcast();
        for (0 => int i; i < NUM_SHELLS; 1 +=> i) {
            get_vel(vel) => vec3 velocity;
            shells[i].set_pos_world(initial_pos);
            shells[i].activate();
            shells[i].update(velocity, @(0, 0, 0));
            spork ~ fader(shells[i], 350::ms);
            delay(del);
        }
        shell_fade(3::second);
        for (0 => int i; i < NUM_SHELLS; 1 +=> i) {
            reset(shells[i]);
        }
        reset_signal.broadcast();
    }

    fun void delay(dur delay) {
        now + delay => time end;
        while (now < end) {
            GG.nextFrame() => now;
        }
    }

    // deactivating essentially sets the partical back to it's original position
    // need to reset alpha values, velocities, and position
    fun void reset(Particle @particle) {
        <<< "resetting" >>>;
        0 => particle.ACTIVE;
        particle.reset_physics();
        particle.set_pos_world(initial_pos);
        particle.set_alpha(1);
    }

    fun void shell_fade(dur fade_time) {
        now + fade_time => time end;
        while (now < end) {
            GG.nextFrame() => now;
        }
    }

    fun void fader(Particle @ part, dur fade_time) {
        while (part.get_y_velocity() > -0.1) {
            GG.nextFrame() => now;
        }
        now + fade_time => time end;
        while (now < end) {
            (end - now) / fade_time => float progress;
            part.set_alpha(progress);
            GG.nextFrame() => now;
        }
    }
}
