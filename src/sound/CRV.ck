class Air extends Chugraph {
    Noise n => TwoPole z => BPF bpf => ADSR adsr => outlet;
    SinOsc s => HPF hpf => adsr;
    
    adsr.attackTime(1::second);
    adsr.sustainLevel(1);
    
    0.075 => s.gain;
    1 => z.norm;
    1.0 => z.gain;
    40 => bpf.Q;
    0.99 => z.radius;

    fun void play(int note) {
        adsr.keyOff();
        Std.mtof(note) => bpf.freq;
        Std.mtof(note) => z.freq;
        Std.mtof(note) => s.freq;
        adsr.keyOn();
    }
}

Chorus chor => dac;
0.01 => chor.modFreq;
chor.mix(0.5);
Air air => chor;
Air air2 => chor;
Air air3 => chor;
Air air4 => chor;
Air air5 => chor;
Air air6 => chor;
Air air7 => chor;
Air air8 => chor;
Air air9 => chor;

air.play(83 - 12);
air2.play(84 - 12);
air3.play(88 - 12);
air9.play(90 - 12);
air4.play(91 - 12);
air5.play(95 - 12);
air6.play(79 - 12);
air7.play(76 - 12);
air8.play(72 - 12);

while (true) {
    10::ms => now;
}
