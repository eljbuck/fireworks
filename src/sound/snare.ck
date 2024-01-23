// thanks Tristan
public class Snare extends Chugraph {  
    Noise n => BPF f => ADSR e => outlet;
    400 => f.freq;
    15. => f.Q;
    1.0 => f.gain;
    e.set(1::ms, 50::ms, 0.1, 50::ms);

    fun void play() {
        e.keyOn();
        50::ms => now;
        e.keyOff();
        e.releaseTime() => now;
    }

}