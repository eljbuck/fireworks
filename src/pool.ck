// pool.ck

public class Pool extends GGen {
    // int num_fireworks;
    // string types[];
    // Willow willows[num_fireworks];
    Willow willow;
    Brocade brocade;
    Peony peony;
    Crosette crosette;
    Barrage barrage;
    Palm palm;


    fun void init() {
        willow.init();
        brocade.init();
        peony.init();
        crosette.init();
        barrage.init(@(1, 0, 0));
        palm.init();
    }

    fun void get_palm(vec3 pos, vec3 col) {
        palm --> this;
        spork ~ palm.launch(@(0, 1.45, 0), pos, col);
    }

    fun void get_willow(vec3 pos, vec3 col) {
        willow --> this;
        spork ~ willow.launch(@(0, 1.35, 0), pos, col);
    }

    fun void get_brocade(vec3 pos, vec3 col) {
        brocade --> this;
        spork ~ brocade.launch(@(0, 1.45, 0), pos, col);
    }

    fun void get_peony(vec3 pos, vec3 col) {
        peony --> this;
        spork ~ peony.launch(@(0, 1.45, 0), pos, col);
    }

    fun void get_crosette(vec3 pos, vec3 col) {
        crosette --> this;
        spork ~ crosette.launch(@(0, 1.45, 0), pos, col);
    }

    fun void get_barrage(vec3 pos) {
        barrage --> this;
        barrage.pos(pos);
        spork ~ barrage.launch(@(0, 1.4, 0));
    }
}