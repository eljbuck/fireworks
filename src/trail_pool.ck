// trail_pool.ck


public class TrailPool extends GGen {
    int num_trails;
    GMeshStack stack;
    GMeshStack active;
    @(0,0,0) => vec3 initial_pos;
    // Queue of trail meshes?

    // makes as many trail meshes as there are needed for one firework
    fun void init(int no_trail, int no_star, float rad, Material trail_mat) {
        for (0 => int i; i < no_trail * no_star * 5; 1 +=> i) {
            CircleGeometry trail_geo;
            trail_geo.set(rad, 10, 0, 2 * Math.PI);
            GMesh trail;
            trail.set(trail_geo, trail_mat);
            stack.push(trail);
        }
    }
    
    fun int size() {
        return stack.size();
    }

    fun int active_size() {
        return active.size();
    }

    fun void clean() {
        while (!active.isEmpty()) {
            active.pop() @=> GMesh @trail;
            trail --< this;
            trail.sca(1);
            stack.push(trail);
        }
    }

    // resets trail particle and stack it into the stack
    fun void reset(GMesh @trail) {
        trail --< this;
        // trail.sca(1);
        // stack.push(trail);
        // active.pop();
    }

    // dequeues trail particle and grucks to scene
    fun GMesh @ get(vec3 pos, dur lifespan, float alpha) {
        if (!stack.isEmpty()) {
            stack.pop() @=> GMesh @ trail;
            active.push(trail);
            trail.mat().alpha(alpha);  // when get is updating, it's updating all of the trail particles that have been spawned, not just the one's that are spawning
            trail.posWorld(pos);
            trail --> this;
            return trail;
            // stack.pop() @=> GMesh trail; // THIS SHOULD BE GETTING A NEW PARTICLE !!!!!!!!
            // active.push(trail);
            // spork ~ fade(trail, lifespan, alpha);  // spork ?
        } 
        return NULL;
    }
    
    // fades trail both in alpha and scale
    fun void fade(GMesh @trail, dur lifespan, float cur_alpha) {
        // <<< "fading" >>>;
        now + lifespan => time end;
        while (now < end) {
            (end - now) / lifespan => float progress;
            trail.sca(progress);
            // trail.mat().alpha(cur_alpha);
            GG.nextFrame() => now;
        }
        //reset(trail);
    }

}