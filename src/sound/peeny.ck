public class Peeny extends Chugraph {
    SinOsc s[4];
    LPF lpf => ADSR adsr => outlet;
    lpf.freq(200);
    adsr.set(200::ms, 150::ms, 0.2, 1000::ms);
    for (int i; i < 4; i++) {
        s[i] => lpf;
    }

    [65, 72] @=> int chord1[];
    [67, 72] @=> int chord2[];
    [68, 72] @=> int chord3[];
    [63, 72] @=> int chord4[];
    [64, 72] @=> int chord5[];

    [chord1, chord2, chord3, chord4,
     chord1, chord2, chord3, chord5] @=> int chords[][];

    fun void play() {
        <<< "playing" >>>;
        adsr.keyOn();
        500::ms => now;
        adsr.keyOff();

    }

    fun void play_chord(int index) {
        <<< "playing chord" >>>;
        if (index == -1) {
            0 => index;
        }
        Std.mtof(chords[index][0]) => s[0].freq;
        Std.mtof(chords[index][0]) + 1 => s[1].freq;
        <<< s[0].freq() >>>;
        Std.mtof(chords[index][1]) => s[2].freq;
        Std.mtof(chords[index][1]) - 1 => s[3].freq;
        play();
    }
}