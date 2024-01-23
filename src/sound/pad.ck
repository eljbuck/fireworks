public class Pad {
 SawOsc saw[5];
 SqrOsc sqr[5];
 ADSR e => LPF f => NRev r => Gain g => dac;

 12 => float low;

 for (auto @ s : saw) s => e;
 for (auto @ s : sqr) s => e;

 (1::second, 1000::ms, 0.5, 2::second) => e.set;
 0.75 => r.mix;
 0.01 / (saw.size() + sqr.size()) => g.gain;
 5 => f.Q;

 fun void wow(float freq) {
   now => time start;
   while (now - start < 7::second) {
  ((now - start) / second) => float elapsed;
     (Math.E, -elapsed) => Math.pow => float amp;
     (amp + 0.5) * (5 * elapsed => Math.sin) * freq + freq * 4 / 3 => f.freq;
     10::ms => now;
   }
 }

 fun void play(float midi) {
   for (auto @ s : saw) ((-0.1, 0.1) => Math.random2f) + midi => Std.mtof => s.freq;
   for (auto @ s : sqr) ((-0.1, 0.1) => Math.random2f) + midi - low => Std.mtof => s.freq;

   midi => Std.mtof => float freq;
   freq => saw[0].freq;
   freq => sqr[0].freq;

   // spork ~ wow(freq);

   e.keyOn();
   5::second => now;
   e.keyOff();
   5::second => now;
 }
}

Pad pad;

while (true) {
    pad.play(60);
}