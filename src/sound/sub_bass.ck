// name: sub_bass.ck
// =================
// author: Ethan Buck
// date: 12/04/2023
//
// desc: sub bass instrument

public class SubBass extends Chugraph {
    SawOsc osc1 => LPF lpf => ADSR adsr => Gain osc_gain => outlet;
    SawOsc osc2 => lpf;

    1.2 => osc_gain.gain;

    lpf.freq(300);

    osc1.gain(0.1);
    osc2.gain(0.3);

    // 1::ms => adsr.attackTime;
    // 10::second => adsr.decayTime;
    // 0.75 => adsr.sustainLevel;
    // 1500::ms => adsr.releaseTime;

    adsr.attackTime(3::ms);
    adsr.decayTime(100::ms);
    adsr.sustainLevel(0.1);
    adsr.releaseTime(300::ms);
    // adsr.decayRate(0.000001);

    10 => float filter_cutoff;
    0 => float filter_env;

    1 => float osc2_detune;
    0 => int osc1_offset;
    -12 => int osc2_offset;

    fun void key_on() {
        1 => adsr.keyOn;
    }

    fun void key_off() {
        1 => adsr.keyOff;
    }

    fun void set_note(int note_number) {
        Std.mtof(note_number + osc1_offset) => osc1.freq;
        Std.mtof(note_number + osc2_offset) - osc2_detune => osc2.freq;
    }

}

// [ 46 + 24, 53 + 24, 60 + 24, 62 + 24, 69 + 24 ] @=> int b_flat_maj[];
// Pad voices[5];
// for (0 => int i; i < voices.size(); 1 +=> i) {
//     voices[i] => dac;
//     voices[i].set_note(b_flat_maj[i]);
// }

// while (true) {
//     for (0 => int i; i < voices.size(); 1 +=> i) {
//         voices[i].key_on();
//     }

//     5::second => now;
//     for (0 => int i; i < voices.size(); 1 +=> i) {
//         voices[i].key_off();
//     }
//     5::second => now;
// }