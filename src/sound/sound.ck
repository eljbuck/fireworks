class SynthVoice extends Chugraph {
    SawOsc saw1 => LPF lpf => ADSR adsr => outlet;
    SawOsc saw2 => lpf;

    TriOsc tri1, tri2;
    SqrOsc sqr1, sqr2;

    SinOsc sin_lfo;
    SawOsc saw_lfo;
    SqrOsc sqr_lfo;
    sin_lfo => Gain pitch_lfo => blackhole;
    sin_lfo => Gain filter_lfo => blackhole;

    fun void set_lfo_freq(float frequency) {
        frequency => sin_lfo.freq => saw_lfo.freq => sqr_lfo.freq;
    }

    6.0 => set_lfo_freq;
    0 => filter_lfo.gain;
    0 => pitch_lfo.gain;

    2 => saw1.sync => saw2.sync => tri1.sync => tri2.sync => sqr1.sync => sqr2.sync;
    pitch_lfo => saw1;
    pitch_lfo => saw2;
    pitch_lfo => tri1;
    pitch_lfo => tri2;
    pitch_lfo => sqr1;
    pitch_lfo => sqr2;  
    
    0.05 => tri1.gain => tri2.gain;
    0.05 => saw1.gain => saw2.gain;
    0.05 => sqr1.gain => sqr2.gain;

    10 => float filter_cutoff;
    filter_cutoff => lpf.freq;

    1000::ms => adsr.attackTime;
    500::ms => adsr.decayTime;
    0.5 => adsr.sustainLevel;
    1000::ms => adsr.releaseTime;

    0 => float filter_env;

    1 => float osc2_detune;
    0 => int osc_offset;

    fun void process_lfo() {
        while (true) {
            filter_cutoff + filter_lfo.last() => lpf.freq;
            5::ms => now;
        }
    }
    spork ~process_lfo();

    fun void set_osc1_freq(float frequency) {
        frequency => tri1.freq => sqr1.freq => saw1.freq;
    }

    fun void set_osc2_freq(float frequency) {
        frequency => tri2.freq => sqr2.freq => saw2.freq;
    }

    fun void cutoff(float amount) {
        if (amount > 100) {
            100 => amount;
        }
        if (amount < 0) {
            0 => amount;
        }
        (amount / 100) * 5000 => filter_cutoff;
        10::ms => now;
    }

    fun void rez(float amount) {
        if (amount > 100) {
            100 => amount;
        }
        if (amount < 0) {
            0 => amount;
        }
        20 * (amount / 100) + 0.3 => lpf.Q;
    }

    fun void env(float amount) {
        if (amount > 100) {
            100 => amount;
        }
        if (amount < 0) {
            0 => amount;
        }
        5000 * (amount / 100) => filter_env;
    }

    fun void key_on() {
        1 => adsr.keyOn;
        spork ~ filter_envelope();
    }

    fun void filter_envelope() {
        filter_cutoff => float start_freq;
        10::ms => now;
        while ((adsr.state() != 0 && adsr.value() == 0) == false) {
            (filter_env * adsr.value()) + start_freq => lpf.freq;
            20::ms => now;
        }
    }

    fun void key_off() {
        1 => adsr.keyOff;
    }

    fun void detune(float amount) {
        if (amount > 100) {
            100 => amount;
        }
        if (amount < 0) {
            0 => amount;
        }
        5 * (amount / 100) => osc2_detune;
    }

    fun void pitch_mod(float amount) {
        if (amount > 100) {
            100 => amount;
        }
        if (amount < 0) {
            0 => amount;
        }
        84 * (amount / 100) => pitch_lfo.gain;
    }

    fun void cutoff_mod(float amount) {
        if (amount > 100) {
            100 => amount;
        }
        if (amount < 1) {
            0 => amount;
        }
        500 * (amount / 100) => filter_lfo.gain;
    }

    fun void set_note(int note_number) {
        Std.mtof(note_number) => set_osc1_freq;
        Std.mtof(note_number + osc_offset) - osc2_detune => set_osc2_freq;
    }

    fun void choose_osc1(int osc_type) {
        if (osc_type == 0) {
            tri1 =< lpf;
            saw1 =< lpf;
            sqr1 =< lpf;
        }
        if (osc_type == 1) {
            tri1 => lpf;
            saw1 =< lpf;
            sqr1 =< lpf;
        }
        if (osc_type == 2) {
            tri1 =< lpf;
            saw1 => lpf;
            sqr1 =< lpf;
        }
        if (osc_type == 3) {
            tri1 =< lpf;
            saw1 =< lpf;
            sqr1 => lpf;
        }
    }
    fun void choose_osc2(int osc_type) {
        if (osc_type == 0) {
            tri2 =< lpf;
            saw2 =< lpf;
            sqr2 =< lpf;
        }
        if (osc_type == 1) {
            tri2 => lpf;
            saw2 =< lpf;
            sqr2 =< lpf;
        }
        if (osc_type == 2) {
            tri2 =< lpf;
            saw2 => lpf;
            sqr2 =< lpf;
        }
        if (osc_type == 3) {
            tri2 =< lpf;
            saw2 =< lpf;
            sqr2 => lpf;
        }
    }

    fun void choose_lfo(int osc_type) {
        if (osc_type == 0) {
            sin_lfo =< filter_lfo;
            sin_lfo =< pitch_lfo;
            saw_lfo =< filter_lfo;
            saw_lfo =< pitch_lfo;
            sqr_lfo =< filter_lfo;
            sqr_lfo =< pitch_lfo;
        }
        if (osc_type == 1) {
            sin_lfo => filter_lfo;
            sin_lfo => pitch_lfo;
            saw_lfo =< filter_lfo;
            saw_lfo =< pitch_lfo;
            sqr_lfo =< filter_lfo;
            sqr_lfo =< pitch_lfo;
        }
        if (osc_type == 2) {
            sin_lfo =< filter_lfo;
            sin_lfo =< pitch_lfo;
            saw_lfo => filter_lfo;
            saw_lfo => pitch_lfo;
            sqr_lfo =< filter_lfo;
            sqr_lfo =< pitch_lfo;
        }
        if (osc_type == 3) {
            sin_lfo =< filter_lfo;
            sin_lfo =< pitch_lfo;
            saw_lfo =< filter_lfo;
            saw_lfo =< pitch_lfo;
            sqr_lfo => filter_lfo;
            sqr_lfo => pitch_lfo;
        }
    }
}


[ 46, 53, 60, 62, 69 ] @=> int b_flat_maj[];
SynthVoice voices[5];
for (0 => int i; i < voices.size(); 1 +=> i) {
    voices[i] => dac;
    voices[i].choose_osc1(2);
    voices[i].choose_osc2(3);
    voices[i].choose_lfo(3);
    voices[i].set_lfo_freq(6);
    voices[i].detune(2);
    voices[i].set_note(b_flat_maj[i]);
}

while (true) {
    int val;
    for (0 => int i; i < 11; 1 +=> i) {
        i * 10 => val;
        <<< val >>>;
        for (0 => int i; i < voices.size(); 1 +=> i) {
            voices[i].cutoff(20);
            voices[i].env(20);
            voices[i].rez(1);
            voices[i].pitch_mod(.25);
            voices[i].cutoff_mod(10);
            voices[i].key_on();
            
        }
        4000::ms => now;
        for (0 => int i; i < voices.size(); 1 +=> i) {
            voices[i].key_off();    
        }
        1000::ms => now;
    }
}