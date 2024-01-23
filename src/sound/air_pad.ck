// naem: pad.ck
// ==================
// author: Ethan Buck
// date: 12/04/23
//
// desc: ethereal pads

class AirPad extends Chugraph {
    SinOsc osc1 => HPF hpf => LPF lpf => ADSR adsr => Gain osc_gain => outlet;
    SinOsc osc2 => hpf;
    SawOsc osc3 => hpf;
    // KrstlChr chr => outlet;
    Noise noise => BiQuad f => hpf;

    0.35 => osc_gain.gain;


    hpf.freq(300);
    lpf.freq(1100);

    osc1.gain(0.1);
    osc2.gain(0.2);
    osc3.gain(0.1);
    // chr.gain(1.0);
    noise.gain(0.1);
    f.gain(0.1);
    .75 => f.prad;
    1 => f.eqzs;
    1500 => f.pfreq;

    50::ms => adsr.attackTime;
    500::ms => adsr.decayTime;
    0.75 => adsr.sustainLevel;
    1000::ms => adsr.releaseTime;

    10 => float filter_cutoff;
    0 => float filter_env;

    1 => float osc2_detune;
    1 => float osc3_detune;
    -12 => int osc2_offset;
    -24 => int osc3_offset;
    -36 => int sub_offset;

    fun void key_on() {
        1 => adsr.keyOn;
        adsr.decayTime() => now;
        1 => adsr.keyOff;
    }

    fun void key_off() {
        1 => adsr.keyOff;
    }

    fun void set_note(int note_number) {
        Std.mtof(note_number) => osc1.freq;
        Std.mtof(note_number + osc2_offset) - osc2_detune => osc2.freq;
        Std.mtof(note_number + osc3_offset) - osc3_detune => osc3.freq;
    }

}

public class Roll extends Chugraph {
    AirPad pads[6];
    for (int i; i < 6; i++) {
        pads[i] => outlet;
    }
    [65, 72, 79, 75, 77, 84] @=> int pattern_one[];
    [67, 75, 80, 77, 79, 84] @=> int pattern_two[];
    [68, 77, 82, 79, 80, 84] @=> int pattern_three[];
    [72, 75, 82, 79, 80, 84] @=> int pattern_four[];
    [65, 74, 79, 76, 77, 84] @=> int pattern_five[];
    [pattern_one, pattern_two, pattern_three, pattern_four,
     pattern_one, pattern_two, pattern_three, pattern_five] @=> int pattern_prog[][];

    fun void play(int index) {
        if (index == -1) {
            7 => index;
        }
        for (int i; i < 6; i++) {
            pads[i].set_note(pattern_prog[index][i]);
            spork ~ pads[i].key_on();
            Math.random2f(50, 75)::ms => now;
        }
    } 
}