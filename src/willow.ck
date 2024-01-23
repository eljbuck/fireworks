// willow.ck
global Event willow_boom;
global Event willow_launch;
global Event reset_signal;

public class Willow extends GGen {
    200 => int NUM_STARS;
    10 => int TRAIL_LENGTH;
    1000::ms => dur LIFESPAN;
    Particle shell --> this;
    vec3 initial_pos;
    Particle stars[NUM_STARS];
    vec3 new_velocities[NUM_STARS];

    FlatMaterial shell_mat;
    vec3 initial_vel;
    TrailPool trail_pool;
    FlatMaterial trail_mat;
    trail_mat.color(@(1, 1, 1));
    trail_pool.init(TRAIL_LENGTH, NUM_STARS, 0.15, trail_mat);
    trail_pool.size() => int initial_size;

    @(0, -.0125, 0) => vec3 gravity;

    fun void init() {
        shell.init(gravity, shell_mat, trail_pool, LIFESPAN, 25, 0);
        for (0 => int i; i < NUM_STARS; 1 +=> i) {
            stars[i] --> this;
            rand_unit_vec() * Math.random2f(0.01, 0.35) => new_velocities[i];
            stars[i].init(0.05 * shell.gravity, shell_mat, trail_pool, LIFESPAN, TRAIL_LENGTH, 0);
        }
    }

    fun void launch(vec3 vel, vec3 pos, vec3 c) {
        willow_launch.broadcast();
        shell_mat.color(c);
        pos => initial_pos;
        vel => initial_vel;
        shell.set_pos_world(initial_pos);
        shell.activate();
        shell.update(initial_vel, @(0, 0, 0));
        while (shell.get_y_velocity() > -.1) {
            GG.nextFrame() => now;
        }
        
        boom(400::ms);
    }

    // generate random 2d unit vector
    fun vec3 rand_unit_vec() {
        Math.random2f(-1, 1) => float x;
        Math.sqrt(1 - (x * x)) => float y;
        if (Math.random2(0, 1)) {
            -1 *=> y;
        }
        return @(x, y, 0);
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
        0 => particle.ACTIVE;
        particle.reset_physics();
        particle.set_pos_world(initial_pos);
        particle.set_alpha(1);
    }

    fun void boom(dur del) {
        <<< "boom" >>>;
        shell.get_pos_world() => vec3 cur_pos;
        // when shell gets reset, the trails are not being reset properly 
        spork ~ shell_fade(1::second);
        delay(del);
        willow_boom.broadcast();
        for (0 => int i; i < NUM_STARS; 1 +=> i) {
            // willow_boom.broadcast();
            // 1 => stars[i].BOOMED;
            stars[i].set_pos_world(cur_pos);
            stars[i].activate();
            spork ~ stars[i].update(new_velocities[i], @(0, 0, 0));
            spork ~ stars[i].apply_force( -0.005 * new_velocities[i]);
        }
        delay(2::second);
        star_fade(4::second);
        // at this point, all of the particles are faded, and we want to clean up the trails
        trail_pool.clean();
        reset_signal.broadcast();
        <<< "trail_pool initial size:",  initial_size >>>;
        <<< "trail_pool size:", trail_pool.size() >>>;
        <<< "trail_pool active size:", trail_pool.active_size() >>>;
        for (0 => int i; i < NUM_STARS; 1 +=> i) {
            reset(stars[i]);
        }
        this --< this.parent();
    }

    fun void shell_fade(dur fade_time) {
        shell.set_pos_world(@(0,0,0));
        now + fade_time => time end;
        while (now < end) {
            GG.nextFrame() => now;
        }
        reset(shell);
    }

    fun void star_fade(dur fade_time) {
        now + fade_time => time end;
        while (now < end) {
            (end - now) / fade_time => float progress;
            for (0 => int i; i < NUM_STARS; 1 +=> i) {
                stars[i].set_alpha(progress);
            }
            GG.nextFrame() => now;
        }
    }
}
