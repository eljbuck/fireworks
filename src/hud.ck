global float camPos[];
-1 => global int selected;
true => global int hudding;
global Event hotkeying;
-1 => global int hotkey;

public class Dock extends GGen {


	Mouse @ mouse;

	["palm.png", "crosette.png", "barrage.png", "brocade.png", "peony.png", "willow.png"] @=> string textures[];
	textures.size() => int count;
	GPlane bar[count];
	FileTexture tex[count];
	FlatMaterial m[count];
	0.5 => float bsize;

	for (int i; i < count; i++) {
		me.dir() + "thumbnails/" + textures[i] => tex[i].path;
		tex[i] => m[i].diffuseMap;
		false => m[i].transparent;

		bar[i] @=> auto b;

		m[i] => b.mat;

		b --> this;

		@(bsize, bsize, bsize) => b.sca;

	 	-bsize * bar.size() / 2. + i * bsize * 1.1 => b.posX;
	}

	spork ~ handleClick();
	spork ~ handleHotkey();

	fun void handleClick() {
		while (true) {
			mouse.mouseDownEvents[0] => now;

			for (int i; i < count; i++) {
				bar[i] @=> auto @ b;
				b.scaWorld() => vec3 worldScale;
				worldScale.x / 2. => float halfWidth;
				worldScale.y / 2. => float halfHeight;
				b.posWorld() => vec3 worldPos;

        if (mouse.worldPos.x > worldPos.x - halfWidth && mouse.worldPos.x < worldPos.x + halfWidth &&
          mouse.worldPos.y > worldPos.y - halfHeight && mouse.worldPos.y < worldPos.y + halfHeight) {
          if (i == selected) {
            true => hudding;
            -1 => selected;
            break;
          }

          @(0.7, 0.7, 0.7) => b.mat().color;
          i => selected;
        }
      }
		}
	}

	fun void handleHotkey() {
		while (true) {
			hotkeying => now;

			bar[hotkey - 1] @=> auto @ b;
			@(0.7, 0.7, 0.7) => b.mat().color;
			hotkey - 1 => selected;
		}
	}

	fun void update(float dt) {
		@(camPos[0], camPos[1] - 3, camPos[2] - 0.5) => posWorld;

		int _hud;

		for (int i; i < count; i++) {
			bar[i] @=> auto @ b;
			b.scaWorld() => vec3 worldScale;
			worldScale.x / 2. => float halfWidth;
			worldScale.y / 2. => float halfHeight;
			b.posWorld() => vec3 worldPos;

			if (i == selected) continue;

			if (mouse.worldPos.x > worldPos.x - halfWidth && mouse.worldPos.x < worldPos.x + halfWidth &&
				mouse.worldPos.y > worldPos.y - halfHeight && mouse.worldPos.y < worldPos.y + halfHeight) {
				@(0.8, 0.8, 0.8) => b.mat().color;
				true => hudding;
				true => _hud;
			} else {
				@(1, 1, 1) => b.mat().color;
			}
		}

		if (!_hud) false => hudding;
	}
}
