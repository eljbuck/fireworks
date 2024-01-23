// name: fireworks.ck
// ==================
// author: Ethan Buck (feat. HUD implementation from Tristan Wang, ty <3)
// date: 12/12/2023
//
// desc: main game loop for queue-based ambient firework soundscape playground/sequencer

// Global Vars and Events =================================
global float camPos[0];
global int select_pos;
global int num_queued;
global int capacity;
global Event toggle_dock;
global Event toggle_sidebar;
global Event up_arrow;
global Event down_arrow;
global Event launch;
global Event willow_launch;
global Event queued;
global Event peony_queue;
global Event peony_boom;
global Event brocade_queue;
global Event brocade_boom;
global Event willow_queue;
global Event willow_boom;
global Event crosette_queue;
global Event crosette_boom;
global Event crosette_second_boom;
global Event barrage_queue;
global Event barrage_boom;
global Event palm_queue;
global Event palm_boom;
global Event reset_signal;

// Scene Set-up ===========================================
GG.scene().backgroundColor(@(0, 0, 0));
GG.camera().posZ(99);
GG.camera().posY(50);

camPos << GG.camera().posX();
camPos << GG.camera().posY();
camPos << GG.camera().posZ();

// Initialize Mouse Manager ================================
Mouse mouse;
spork ~ mouse.start(0);  // start listening for mouse events
spork ~ mouse.selfUpdate(); // start updating mouse position

// HUD Set-up ==============================================
Dock dock --> GG.scene();
mouse @=> dock.mouse;
Sidebar sidebar --> GG.scene();
mouse @=> sidebar.mouse;

// Firework Pool Set-Up ====================================
Pool pool --> GG.scene();
pool.init();

// Instrument Set-Up =======================================
ChordStab stabber => Gain willow => NRev rev => dac;
Ping ping => Gain palm => rev;
Points points => Gain barrage => rev;
Roll roll => Gain brocade => rev;
Cascade cascade => Gain crosette => rev;
Peeny peeny => Gain peony => rev;
willow.gain(0.8);
palm.gain(1.25);
brocade.gain(0.5);
crosette.gain(0.8);
rev.mix(0.5);

// Notes Set-Up ============================================
0 => int WILLOW_HAPPENED;
0 => int CUR_CHORD_INDEX;
[0, 2, 4, 7, 11] @=> int scale_one[];   // use for Db and Ab
[0, 2, 4, 7, 9] @=> int scale_two[];   // for Eb/C-
[0, 2, 3, 5, 7, 10] @=> int scale_three[]; // for F-/D-
[scale_one, scale_two, scale_three, scale_one,
 scale_one, scale_two, scale_three, scale_three] @=> int scale_prog[][];


// Queue Set-Up ============================================
// 0 = palm
// 1 = crosette
// 2 = barrage
// 3 = brocade
// 4 = peony
// 5 = willow
Queue queue;

// Debugging ===============================================

// spork ~ print_fps();
fun void print_fps() {
    while (true) {
        <<< GG.fps() >>>;
        2::second => now;
    }
}

//spork ~ print_queue();
fun void print_queue() {
    while (true) {
        queue.display();
        2::second => now;
    }
}

// Various Listeners =======================================

// peony sound listener
fun void peony_listener() {
    while (true) {
        peony_boom => now;
        peeny.play_chord(CUR_CHORD_INDEX - 1);
    }
}
spork ~ peony_listener();

// crosette sound listener
fun void crosette_listener_one() {
    while (true) {
        crosette_boom => now;
        cascade.play_lower(CUR_CHORD_INDEX - 1);
    }
}
spork ~ crosette_listener_one();

fun void crosette_listener_two() {
    while (true) {
        crosette_second_boom => now;
        cascade.play_higher(CUR_CHORD_INDEX - 1);
    }
}
spork ~ crosette_listener_two();

// brocade sound listener
fun void brocade_listener() {
    while (true) {
        brocade_boom => now;
        roll.play(CUR_CHORD_INDEX - 1);
    }
}
spork ~ brocade_listener();

// barrage sound listener
fun void barrage_listener() {
    while (true) {
        barrage_boom => now;
        points.play(CUR_CHORD_INDEX - 1);
    }
}
spork ~ barrage_listener();

// palm sound listener
fun void palm_listener() {
    while (true) {
        palm_boom => now;
        scale_prog[CUR_CHORD_INDEX - 1] @=> int scale[];
        <<< scale[scale.size() - 1] >>>;
        scale[Math.random2(0, scale.size() - 1)] => int note;
        spork ~ ping.play(get_root() + 12 + note);
    }
}
spork ~ palm_listener();

// willow sound listener
fun void willow_player() {
    while (true) {
        willow_boom => now;
        if (WILLOW_HAPPENED == 0) {
            0 => CUR_CHORD_INDEX;
            WILLOW_HAPPENED++;
        }
        <<< "willow boom happened" >>>;
        CUR_CHORD_INDEX++;
        if (CUR_CHORD_INDEX > 8) {
            1 => CUR_CHORD_INDEX;
        }
        stabber.play_chord(CUR_CHORD_INDEX);    // spork?
    }
}
spork ~ willow_player();

fun void willow_releaser() {
    while (true) {
        willow_launch => now;
        <<< "willow launch happened" >>>;
        stabber.release();
    }
}
spork ~ willow_releaser();

// broadcasts up arrow event
fun void detect_up_arrow() {
    while (true) {
        if (KB.isKeyDown(KB.KEY_UP)) {
            up_arrow.broadcast();
        }
        250::ms => now;
    }
}
spork ~ detect_up_arrow();

// broadcasts down arrow event
fun void detect_down_arrow() {
    while (true) {
        if (KB.isKeyDown(KB.KEY_DOWN)) {
            down_arrow.broadcast();
        }
        250::ms => now;
    }
}
spork ~ detect_down_arrow();

// broadcasts space event
fun void detect_space() {
    while (true) {
        if (KB.isKeyDown(KB.KEY_SPACE)) {
            <<< "toggle" >>>;
            toggle_dock.broadcast();
            toggle_sidebar.broadcast();
        }
        250::ms => now;
    }
}
spork ~ detect_space();

// enqueues current selection
fun void detect_enter() {
    while (true) {
        if (KB.isKeyDown(KB.KEY_ENTER)) {
            if (num_queued < capacity) {
                queue.enqueue(select_pos);
                dock.enter_queue(select_pos);
            }
        }
        250::ms => now;
    }
}
spork ~ detect_enter();

// Util Functions ====================================
fun int get_root() {
    if (CUR_CHORD_INDEX == 1 || CUR_CHORD_INDEX == 5) {
        return 61;
    } else if (CUR_CHORD_INDEX == 2 || CUR_CHORD_INDEX == 6) {
        return 63;
    } else if (CUR_CHORD_INDEX == 3 || CUR_CHORD_INDEX == 7) {
        return 65;
    } else if (CUR_CHORD_INDEX == 4) {
        return 68;
    } else {
        return 62;
    }
}

fun void delay(dur t) {
    now + t => time end;
    while (now < end) {
        GG.nextFrame() => now;
    }
}

fun int get_random_index() {
    Math.random2(0, 4) => int index;
    if (index == 2) {
        Math.random2(0, 4) => index;
    }
    return index;
}

fun void queue_stocker() {
    while (true) {
        if (queue.size() < 1) {
            get_random_index() => int index;
            queue.enqueue(index);
            dock.enter_queue(index);
        }
        GG.nextFrame() => now;
    }
}
spork ~ queue_stocker();

fun vec3 random_color() {
    [Color.BLUE, Color.GOLD, Color.GREEN, Color.LIME, Color.MAGENTA, 
     Color.ORANGE, Color.PINK, Color.PURPLE, Color.RED, Color.SKYBLUE,
     Color.VIOLET, Color.YELLOW] @=> vec3 colors[];

    return colors[Math.random2(0, colors.size() - 1)];
}

// Fireworks Spawning ===================================

fun void spawn_fireworks() {
    delay(5::second);
    while (true) {
        <<< WILLOW_HAPPENED >>>;
        if (WILLOW_HAPPENED == 0) {
            Math.random2(1, 8) => CUR_CHORD_INDEX;
            <<< "index: ", CUR_CHORD_INDEX >>>;
        }
        Math.random2(-35, 35) => int x;
        
        random_color() => vec3 col;
        @(x, 0, 0) => vec3 p;
        queue.dequeue() => int index;
        5.5::second => dur wait;
        if (index == 0) {
            pool.get_palm(p, col);
        } else if (index == 1) {
            pool.get_crosette(p, col);
        } else if (index == 2) {
            pool.get_barrage(@(0, 0, 0));
        } else if (index == 3) {
            pool.get_brocade(p, col);
        } else if (index == 4) {
            pool.get_peony(p, col);
        } else if (index == 5) {
            Math.random2(-10, 10) => int wx;
            pool.get_willow(@(wx, 0, 0), col);
            10::second => wait;
        }
        delay(wait);
        dock.slide();
    }
}
spork ~ spawn_fireworks();

while ( true ) {
    GG.nextFrame() => now;  
}