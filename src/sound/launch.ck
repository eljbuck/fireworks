class Launch extends Chugraph {
    CNoise n => LPF lpf => TwoPole z => ADSR adsr => NRev rev => dac;
 
    rev.mix(0.05);
     
    0.25 => n.gain;
    "pink" => n.mode;
    
    adsr.set(35::ms, 75::ms, 0.2, 50::ms);
 
     
    0.5 => z.radius;
    0.5 => z.gain;
    400 => z.freq;
    3000 => lpf.freq;
    
    fun void play() {
        adsr.keyOn();
        adsr.attackTime() => now;
        adsr.decayTime() => now;
        adsr.keyOff();
    }
    
}