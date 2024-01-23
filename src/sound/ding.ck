// ding.ck
// name: ping.ck
// =============
// author: Ethan Buck
// date: 12/04/2023
// 
// desc: firework pops

class Ding extends Chugraph {

    Noise n => BPF f => LPF lf => ADSR e => outlet;
    700 => f.freq;
    60. => f.Q;
    15 => f.gain;
    // e.set(5::ms, 50::ms, 0.1, 50::ms);
    e.set(1::ms, 150::ms, 0.1, 3::second);
    lf.freq(400);

    n.gain(0.1);

    SinOsc osc1 => HPF hpf => LPF lpf => ADSR adsr => Gain osc_gain => outlet;
    TriOsc osc2 => hpf;

    0.1 => osc_gain.gain;

    hpf.freq(100);
    lpf.freq(500);

    osc1.gain(0.6);
    osc2.gain(0.6);

    adsr.attackTime(2::ms);
    adsr.decayTime(150::ms);
    adsr.sustainLevel(0.05);
    adsr.releaseTime(150::ms);

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

public class Points extends Chugraph {
    Ding ding1 => outlet;
    Ding ding2 => Gain two => outlet;
    two.gain(2.0);

    [60, 61, 68, 67, 72, 77, 70] @=> int pattern_one[];
    [63, 65, 68, 67, 72, 77, 70] @=> int pattern_two[];     
    [65, 68, 73, 72, 79, 84, 77] @=> int pattern_three[];   
    [67, 68, 73, 72, 79, 84, 77] @=> int pattern_four[];
    [64, 65, 70, 69, 76, 81, 74] @=> int pattern_five[]; 
    [pattern_one, pattern_two, pattern_three, pattern_four,
     pattern_one, pattern_two, pattern_three, pattern_five] @=> int pattern_prog[][];

    fun void play_pattern(Ding @ding, int pattern[]) {
        for (int i; i < pattern.size(); i++) {
            spork ~ ding.play(pattern[i]);
            Math.random2f(500, 600)::ms => now;
        }
        <<< "happening" >>>;
    }

    fun void play(int index) {
        spork ~ play_pattern(ding1, pattern_prog[index]);
        250::ms => now;
        spork ~ play_pattern(ding2, pattern_prog[index]);
    }
}