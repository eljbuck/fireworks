// particle_new_new.ck

public class Particle extends GGen {
    100 => int DT_CONSTANT;
    0.35 => float RADIUS;
    dur LIFESPAN;  // make # of active shreds < threshold
    float NUM_TRAILS;
    LIFESPAN / NUM_TRAILS => dur PERIOD;
    int FADE;
    vec3 vel;
    vec3 accel;
    vec3 gravity;
    0 => int ACTIVE;
    TrailPool @trail_pool;

    CircleGeometry particle_geo;
    particle_geo.set(RADIUS, 10, 0, 2 * Math.PI);
    GMesh particle --> this;

    fun void init (vec3 g, Material@ shell_mat, TrailPool @pool, dur lifespan, float num_trails, int fade) {
        lifespan => LIFESPAN;
        num_trails => NUM_TRAILS;
        if (NUM_TRAILS == 0) {
            0::ms => PERIOD;
        } else {
            LIFESPAN / NUM_TRAILS => PERIOD;
        }
        fade => FADE;
        g => gravity;
        particle.set(particle_geo, shell_mat);
        pool @=> trail_pool;
        trail_pool --> this;
    }

    fun float get_y_velocity() {
        return vel.y;
    }

    fun vec3 get_pos_world() {
        return particle.posWorld();
    }

    fun void set_pos_world(vec3 pos) {
        particle.posWorld(pos);
    }

    fun void set_sca(float val) {
        particle.sca(val);
    }

    fun void set_alpha(float val) {
        particle.mat().alpha(val);
    }

    fun void activate() {
        1 => ACTIVE;
        if (PERIOD != 0::ms) {
            spork ~ start_trail(PERIOD);
        }
        spork ~ update_particle();
    }

    fun void start_trail(dur delay) {
        while (ACTIVE) {
            now + delay => time end;
            trail_pool.get(particle.posWorld(), LIFESPAN, particle.mat().alpha()) @=> GMesh @ trail;
            // <<< counter >>>;
            if (FADE) {
                spork ~ trail_pool.fade(trail, LIFESPAN, particle.mat().alpha());
            }
            while (now < end) {
                GG.nextFrame() => now;
            }

        }
    }

    fun void update_particle() {
        while (ACTIVE) {
            accel * GG.dt() * DT_CONSTANT +=> vel;
            particle.pos(particle.pos() + vel * GG.dt() * DT_CONSTANT);
            GG.nextFrame() => now;
        }
        GG.nextFrame() => now;
    }

    fun void reset_physics() {
        vel * 0 => vel;
        accel * 0 => accel;
    }

    fun void update(vec3 new_vel, vec3 force) {
        new_vel +=> vel;
        accel * 0 => accel;
        gravity + force +=> accel;
    }

    fun void apply_force(vec3 force) {
        vel => vec3 initial;
        this.update(@(0, 0, 0), force);
        while (Math.fabs(vel.x) > Math.fabs(0.05 * initial.x)) {
            GG.nextFrame() => now;
        }
        this.update(@(0, 0, 0), @(0, 0, 0));
    }

}