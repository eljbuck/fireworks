// name: ping.ck
// =============
// author: Ethan Buck
// date: 12/04/2023
// 
// desc: firework pops

class Ping extends Chugraph {

    Noise n => BPF f => LPF lf => ADSR e => outlet;
    700 => f.freq;
    60. => f.Q;
    5 => f.gain;
    // e.set(5::ms, 50::ms, 0.1, 50::ms);
    e.set(1::ms, 150::ms, 0.1, 3::second);
    lf.freq(400);

    n.gain(0.1);

    SinOsc osc1 => HPF hpf => LPF lpf => ADSR adsr => Gain osc_gain => outlet;
    TriOsc osc2 => hpf;

    0.2 => osc_gain.gain;

    hpf.freq(100);
    lpf.freq(500);

    osc1.gain(0.8);
    osc2.gain(0.4);

    adsr.attackTime(2::ms);
    adsr.decayTime(150::ms);
    adsr.sustainLevel(0.05);
    adsr.releaseTime(500::ms);

    10 => float filter_cutoff;
    0 => float filter_env;

    fun void play(int note_number) {
        this.set_note(note_number);
        1 => adsr.keyOn;
        // e.keyOn();
        adsr.decayTime() => now;
        e.keyOff();
        1 => adsr.keyOff;
        adsr.releaseTime() => now;
    }

    fun void key_off() {
        1 => adsr.keyOff;
    }

    fun void set_note(int note_number) {
        Std.mtof(note_number) => osc1.freq;
        Std.mtof(note_number) => osc2.freq;
    }

}

public class Cascade extends Chugraph {
    Ping pings[4];
    for (int i; i < 4; i++) {
        pings[i] => outlet;
    }

    [61, 68, 72, 77] @=> int chord11[];
    [68, 75, 77, 84] @=> int chord12[];
    [63, 70, 72, 79] @=> int chord21[];
    [72, 77, 79, 84] @=> int chord22[];
    [65, 72, 75, 80] @=> int chord31[];
    [75, 79, 80, 84] @=> int chord32[];
    [68, 72, 77, 82] @=> int chord41[];
    [75, 79, 80, 84] @=> int chord42[];
    [65, 69, 72, 76] @=> int chord51[];
    [72, 76, 79, 84] @=> int chord52[];
    [chord11, chord21, chord31, chord41,
    chord11, chord21, chord31, chord51] @=> int chord1_prog[][];
    [chord12, chord22, chord32, chord42,
    chord12, chord22, chord32, chord52] @=> int chord2_prog[][];

    fun void play_lower(int index) {
        if (index == -1) {
            0 => index;
        }
        for (int i; i < 4; i++) {
            spork ~ pings[i].play(chord1_prog[index][i]);
            50::ms => now;
        }
    }

    fun void play_higher(int index) {
        if (index == -1) {
            0 => index;
        }
        for (int i; i < 4; i++) {
            spork ~ pings[i].play(chord2_prog[index][i]);
            50::ms => now;
        }
    }
}