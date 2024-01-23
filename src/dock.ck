global float camPos[];
0 => global int num_queued;
global int select_pos;
global int capacity;
global Event hotkeying;
global Event toggle_dock;
global Event queued;
-1 => global int dock_state;

public class Dock extends GGen {
	Mouse @ mouse;

	["palm.png", "crosette.png", "barrage.png", "brocade.png", "peony.png", "willow.png", "black.png", "black.png"] @=> string textures[];
	textures.size() => int count;
    count => capacity;
	GPlane bar[count];
    GPlane border[count];
	FileTexture tex[count];
	FlatMaterial m[count];
	0.03 => float bsize;
    -0.25 => float y_offset_hidden;   // dock initially hidden
    -0.186 => float y_offset_shown;
    y_offset_hidden => float y_offset;

	for (int i; i < count; i++) {
		me.dir() + "thumbnails/" + textures[i] => tex[i].path;
		tex[i] => m[i].diffuseMap;
		false => m[i].transparent;

		bar[i] @=> auto b;

        border[i].posZ(-0.000000001);
        border[i].sca(1.05);
        border[i].mat().color(@(0.1176, 0.1176 ,0.1176));

		m[textures.size() - 1] => b.mat;

		b --> this;

        border[i] --> b;

		@(bsize, bsize, bsize) => b.sca;

	 	-bsize * bar.size() / 2. + i * bsize * 1.1 => b.posX;
	}

    spork ~ debug();
    fun void debug() {
        while (true) {
            <<< pos() >>>;
            2::second => now;
        }
    }

    spork ~ toggleDock();

    fun void toggleDock() {
        while (true) {
            toggle_dock => now;
            -1 *=> dock_state;
            if (dock_state > 0) {
                spork ~ showDock();
            } else {
                spork ~ hideDock();
            }
        }
    }

    400::ms => dur animationTime;

    fun void slide() {
        <<< "sliding" >>>;
        for (0 => int i; i < num_queued - 1; 1 +=> i) {
            bar[i + 1].mat() => bar[i].mat;
        }
        num_queued--;
        add_icon(count - 1);

    }

    fun void add_icon(int index) {
        m[index] => bar[num_queued].mat;

    }

    fun void enter_queue(int index) {
        add_icon(index);
        num_queued ++;
    }

    fun void showDock() {       // y_offset start: -4, y_offset end: -3
        now + animationTime => time end;
        y_offset => float initial;
        while (now < end) {
            1 - (end - now) / animationTime => float progress;      // progress 0 -> 1
            initial + progress * (y_offset_shown - y_offset_hidden) => y_offset;
            GG.nextFrame() => now;
        }
        y_offset_shown => y_offset;
    }

    fun void hideDock() {       // y_offset start: -3, y_offset end: -4s
        now + animationTime => time end;
        y_offset => float initial;

        while (now < end) {
            1 - (end - now) / animationTime => float progress;      // progress 0 -> 1
            initial + progress * (y_offset_hidden - y_offset_shown) => y_offset;
            GG.nextFrame() => now;
        }
        y_offset_hidden => y_offset;
    }

	fun void update(float dt) {
		@(camPos[0], camPos[1] + y_offset, camPos[2] - 0.5) => pos;
	}
}
