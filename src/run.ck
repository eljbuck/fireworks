// name: run.ck
// ============
// author: Ethan Buck
// date: 12/12/2023
//
// desc: top-level program to run fireworks.ck

[
    "mouse.ck",
    "KB.ck",
    "dock.ck",
    "sidebar.ck",
    "queue.ck",
    "stack.ck",
    "trail_pool.ck",
    "particle.ck",
    "willow.ck",
    "palm.ck",
    "barrage.ck",
    "brocade.ck",
    "peony.ck",
    "crosette.ck",
    "pool.ck",
    "./sound/stab.ck",
    "./sound/snare.ck",
    "./sound/sub_bass.ck",
    "./sound/ping.ck",
    "./sound/chordstab.ck",
    "./sound/ding.ck",
    "./sound/air_pad.ck",
    "./sound/sin.ck",
    "./sound/peeny.ck",
    "fireworks.ck"
] @=> string files[];

for (auto file : files)
    Machine.add( me.dir() + file );

