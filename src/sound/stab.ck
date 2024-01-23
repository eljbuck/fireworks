class OscA extends Chugraph {
    SinOsc saws[5];

    for (0 => int i; i < saws.size(); 1 +=> i) {
        saws[i] => outlet;
    }

    fun void set_gain(float gain) {
        for (0 => int i; i < saws.size(); 1 +=> i) {
            saws[i].gain(gain);
        }
    }

    fun void set_pitch(int note, float detune) {
        for (0 => int i; i < saws.size(); 1 +=> i) {
            (saws.size() - 1) / 2 => int mid_point;     // for 7, should be 3
            i - mid_point => int diff;                   // for i = 0, diff should be -3 * detune
            saws[i].freq(Std.mtof(note) + diff * detune);
        }
    }
}

class OscB extends Chugraph {
    SawOsc saws[7];

    for (0 => int i; i < saws.size(); 1 +=> i) {
        saws[i] => outlet;
    }

    fun void set_gain(float gain) {
        for (0 => int i; i < saws.size(); 1 +=> i) {
            saws[i].gain(gain);
        }
    }

    fun void set_pitch(int note, float detune) {
        for (0 => int i; i < saws.size(); 1 +=> i) {
            (saws.size() - 1) / 2 => int mid_point;     // for 7, should be 3
            i - mid_point => int diff;                   // for i = 0, diff should be -3 * detune
            saws[i].freq(Std.mtof(note) + diff * detune);
        }
    }
}

public class Stab extends Chugraph {
    1.8 => float master_gain;
    0.01 * master_gain => float saw_gain;
    0.02  * master_gain => float sin_gain;
    0.0 => float detune;

    OscA sins => LPF lpf => ADSR adsr => outlet;
    OscB saws => lpf;

    adsr.attackTime(3::ms);
    adsr.decayTime(100::ms);
    adsr.sustainLevel(0.1);
    adsr.releaseTime(300::ms);
    lpf.freq(600);
    // lpf.Q(60);
    sins.set_gain(sin_gain);
    saws.set_gain(saw_gain);

    fun void set_master_gain(float amt) {
        amt => master_gain;
    }

    fun void set_detune(float amt) {
        amt => detune;
    }

    fun void play(int note) {
        sins.set_pitch(note, detune);
        saws.set_pitch(note, detune);
        adsr.keyOn();    
    }

    fun void release() {
        adsr.keyOff();
    }
}