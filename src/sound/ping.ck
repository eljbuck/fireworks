// name: ping.ck
// =============
// author: Ethan Buck
// date: 12/04/2023
// 
// desc: firework pops

public class Ping extends Chugraph {

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