// name: audio.ck
// ==================
// author: Ethan Buck
// date: 12/04/2023
//
// desc: audio controller for fireworks

// have functions that play diffferent chord progressions with events that trigger each chord change

global Event firework_boom;

AirPad pad[5];
SubBass bass => NRev rev => dac;
Ping ping => rev;

rev.mix(0.5);

7::second => dur SUSTAIN_TIME;
0 => int CUR_CHORD_INDEX;

for (0 => int i; i < pad.size(); 1 +=> i) {
    pad[i] => rev;
}

[0, 7, 7, 2, 7] @=> int voicing_one[]; [0, 2, 2, 3, 1, 1, 2, 1] @=> int scale_one[];
[0, 7, 7, 2, 5] @=> int voicing_two[]; [0, 2, 2, 1, 2, 2, 1, 2] @=> int scale_two[];
[0, 7, 7, 1, 4] @=> int voicing_three[]; // use scale two
[0, 7, 7, 2, 3] @=> int voicing_four[]; [0, 2, 2, 3, 1, 3, 1] @=> int scale_four[];
[0, 7, 7, 3, 5] @=> int voicing_five[]; [0, 2, 1, 2, 2, 2, 1, 2] @=> int scale_five[];

[voicing_one, voicing_two, voicing_three, voicing_four,
 voicing_one, voicing_two, voicing_three, voicing_five] @=> int prog_one[][];

[scale_one, scale_two, scale_two, scale_four, 
 scale_one, scale_two, scale_two, scale_five] @=> int scale_prog_one[][];

[61, 63, 65, 68, 61, 63, 65, 62] @=> int prog_one_notes[];

fun void play_chord(int start_note, int voicing[]) {
    for (0 => int i; i < pad.size(); 1 +=> i) {
        pad[i].key_off();
    }
    500::ms => now;     // let previous chord release
    0 => int last_note;
    bass.set_note(start_note);
    bass.key_on();
    for (0 => int i; i < pad.size(); 1 +=> i) {
        pad[i].set_note(start_note + last_note + voicing[i]);
        last_note + voicing[i] => last_note;
        pad[i].key_on();
    }
    5::second => now;
}

fun void play_progression(int progression[][], int start_notes[], dur sustain_time) {
    while (true) {
        for (0 => int i; i < progression.size(); 1 +=> i) {
            i => CUR_CHORD_INDEX;
            play_chord(start_notes[i], progression[i]);
            SUSTAIN_TIME => now;
        }
    }
}
spork ~ play_progression(prog_one, prog_one_notes, SUSTAIN_TIME);

fun void firework_listener() {
    while (true) {
        firework_boom => now;
        prog_one_notes[CUR_CHORD_INDEX] => int note;
        spork ~ ping.play(note);
    }
}
spork ~ firework_listener();

while (true) {
    1000::ms => now;
}