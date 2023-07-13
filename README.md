# RES OpenFL BIOS

## Usage

project.xml:

```xml
	<haxelib name="res" />
	<haxelib name="res-openfl" />
```

Main sprite:
```haxe
import openfl.display.Sprite;
import res.RES;
import res.openfl.BIOS;
import res.rom.Rom;

class Main extends Sprite {
	public function new() {
		super();

		RES.boot(new BIOS(this), {
			resolution: [128, 128],
			rom: Rom.embed('rom'),
			main: (res) -> {
				update: (dt) -> {},
				render: (fb) -> {}
			}
		});
	}
}
```