global float camPos[];
0 => global int select_pos;
-1 => global int selected;
true => global int hudding;
global Event hotkeying;
global Event toggle_sidebar;
global Event up_arrow;
global Event down_arrow;
-1 => global int sidebar_state;
-1 => global int hotkey;

public class Sidebar extends GGen {


	Mouse @ mouse;

	["palm.png", "crosette.png", "barrage.png", "brocade.png", "peony.png", "willow.png"] @=> string textures[];
	textures.size() => int count;
	GPlane bar[count];
    GPlane border[count];
    GPlane selection;
    selection.posZ(-0.00000000001);
    selection.sca(1.05);
    selection.mat().color(@(1, 0 , 0));
    // 0 => int select_pos;                // corresponds with the order of textures, e.g. select index 0 indicates palm
	FileTexture tex[count];
	FlatMaterial m[count];
	0.03 => float bsize;
    <<< GG.windowWidth() >>>;
    -0.1 => float adjust_hidden;
    -0.2055 => float adjust_shown;
    // 0.23333 => float adjust_hidden; // 0.30 for 2560, 0.395 for 6208
    // 0.18833333333333335 => float adjust_shown; // 0.255 for 2560, 0.35 for 6208
    adjust_hidden => float adjust;
    float x_offset;

	for (int i; i < count; i++) {
		me.dir() + "thumbnails/" + textures[i] => tex[i].path;
		tex[i] => m[i].diffuseMap;
		false => m[i].transparent;

        bar[i].posX(0.395);

		bar[i] @=> auto b;

        border[i].posZ(-0.00000001);
        border[i].sca(1.025);
        border[i].mat().color(@(0.1176, 0.1176 ,0.1176));

		m[i] => b.mat;

        border[i] --> b;

        if (i == 0) {
            selection --> b;
        }

		@(bsize, bsize, bsize) => b.sca;
	 	-bsize * bar.size() / 2. + i * bsize * 1.1 => b.posY;
        b --> this;
	}

    spork ~ toggleSidebar();

    fun void toggleSidebar() {
        while (true) {
            toggle_sidebar => now;
            -1 *=> sidebar_state;
            if (sidebar_state > 0) {
                spork ~ showSidebar();
            } else {
                spork ~ hideSidebar();
            }
        }
    }

    400::ms => dur animationTime;

    spork ~ upListener();

    fun void upListener() {
        while (true) {
            up_arrow => now;
            if (select_pos < textures.size() - 1) {
                move_up();
            }
        }
    }

    spork ~ downListener();

    fun void downListener() {
        while (true) {
            down_arrow => now;
            if (select_pos > 0) {
                move_down();
            }
        }
    }

    fun void move_up() {
        select_pos++;
        selection --< selection.parent();
        selection --> bar[select_pos];
    }

    fun void move_down() {
        select_pos--;
        selection --< selection.parent();
        selection --> bar[select_pos];
    }

    fun void showSidebar() {       // adjust start: 4, ends at 3
        now + animationTime => time end;
        adjust => float initial;
        while (now < end) {
            1 - (end - now) / animationTime => float progress;      // progress 0 -> 1
            initial + progress * (adjust_shown - adjust_hidden) => adjust;
            GG.nextFrame() => now;
        }
        adjust_shown => adjust;
    }

    fun void hideSidebar() {
        now + animationTime => time end;
        adjust => float initial;
        while (now < end) {
            1 - (end - now) / animationTime => float progress;      // progress 0 -> 1
            adjust + progress * (adjust_hidden - adjust_shown) => adjust;
            GG.nextFrame() => now;
        }
        adjust_hidden => adjust;
    }

    spork ~ debug();
    fun void debug() {
        while (true) {
            <<< "sidebar pos:", pos() >>>;
            2::second => now;
        }
    }

	fun void update(float dt) {
        0.000026041666666666658 * GG.frameWidth() + adjust => x_offset;
		@(camPos[0] + x_offset, camPos[1], camPos[2] - 0.5) => pos;
	}
}

// 0.3000 hidden posX
// 0.2550 shown posX
