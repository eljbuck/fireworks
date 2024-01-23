// name: boom_sound.ck
// ===================
// the sound when boom

public class Boom extends Chugraph {
    SawOsc osc1 => LPF lpf => ADSR adsr => outlet;
    SawOsc osc2 => lpf;
    SawOsc osc3 => lpf;
    0.1 => osc1.gain;
    0.1 => osc2.gain;
    0.1 => osc3.gain;
    
    10::ms => adsr.attackTime;
    100::ms => adsr.decayTime;
    .25 => adsr.sustainLevel;
    3::second => adsr.releaseTime;

    fun void play(float freq) {
        freq => osc1.freq;
        5 * (freq / 4) => osc2.freq;
        6 * (freq / 4) => osc3.freq;
        adsr.keyOn();
        100::ms => now;
        adsr.keyOff();
    }
}