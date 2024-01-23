// want to have play_chord function that plays full chord voicing (have all nonlinear filters here)
// want to have release function that releases when the next willow is being launched

public class ChordStab extends Chugraph {
    // harmonic elements
    // =================
    // sub bass
    // stab mid
    // top ping
    // 
    // texture elements
    // ================
    // snare
    // pink noise (or some other noise)

    // chord structure
    // ===============
    // each chord has a root, a voicing and a top note
    
    SubBass bass => outlet;
    Ping ping => outlet;
    Stab stabs[6];
    CNoise n => TwoPole z => ADSR adsr => outlet;
    Snare snare => outlet;

    adsr.attackTime(2::ms);
    adsr.decayTime(150::ms);
    adsr.sustainLevel(0.075);
    adsr.releaseTime(500::ms);
    // adsr.decayRate(0.00002);

    n.mode("pink");
    1 => z.norm;
    0.75 => z.gain;
    0.99 => z.radius;


    for (0 => int i; i < stabs.size(); 1 +=> i) {
        stabs[i] => outlet;
    }
    

    [49, 56, 63, 65, 68, 72] @=> int d_flat[];  // d_flat[0] - 12 is root, d_flat[d_flat.size() - 1] + 12 is top note
    [51, 58, 63, 65, 67, 72] @=> int e_flat[];  // e_flat[0] - 12 is root, e_flat[e_flat.size() - 1] + 12 is top note
    [53, 60, 63, 65, 68, 72] @=> int f[];
    [44, 51, 58, 60, 67, 72] @=> int a_flat[];
    [50, 57, 60, 64, 67, 72] @=> int d[];


    fun void play(int chord[]) {
        chord[0] => int root;
        bass.set_note(root);
        chord[chord.size() - 1] => int top;
        Std.mtof(top + 12) => z.freq;
        spork ~ ping.play(top);
        spork ~ bass.key_on();
        spork ~ snare.play();
        adsr.keyOn();
        for (0 => int i; i < stabs.size(); 1 +=> i) {
            spork ~ stabs[i].play(chord[i]);
        }
    }

    fun void release() {
        spork ~ bass.key_off();
        for (0 => int i; i < stabs.size(); 1 +=> i) {
            spork ~ stabs[i].release();
        }
    }

    fun void play_chord(int index) {
        if (index == 1 || index == 5) { // play d_flat
            play(d_flat);
        } else if (index == 2 || index == 6) { // play e_flat
            play(e_flat);
        } else if (index == 3 || index == 7) { // play f
            play(f);
        } else if (index == 4) { // play a_flat
            play(a_flat);
        } else if (index == 8) { // play d
            play(d);
        }
    }
}

// ChordStab stabber => NRev rev => dac;
// rev.mix(0.4);

// while (true) {
//     stabber.play_chord(1);
//     10::second => now;
//     stabber.release();
//     4::second => now;
//     stabber.play_chord(2);
//     10::second => now;
//     stabber.release();
//     4::second => now;
//     stabber.play_chord(3);
//     10::second => now;
//     stabber.release();
//     4::second => now;
//     stabber.play_chord(4);
//     10::second => now;
//     stabber.release();
//     4::second => now;
//     stabber.play_chord(1);
//     10::second => now;
//     stabber.release();
//     4::second => now;
//     stabber.play_chord(2);
//     10::second => now;
//     stabber.release();
//     4::second => now;
//     stabber.play_chord(3);
//     10::second => now;
//     stabber.release();
//     4::second => now;
//     stabber.play_chord(8);
//     10::second => now;
//     stabber.release();
//     4::second => now;
// }