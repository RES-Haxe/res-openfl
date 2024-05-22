package res.openfl;

import openfl.display.BitmapData;

class CRT extends res.CRT {
	private final bitmapData:BitmapData;

	public function new(bitmapData:BitmapData) {
		super([A, R, G, B]);
		this.bitmapData = bitmapData;
	}

	override function vblank() {
		bitmapData.lock();
	}

	override function vsync() {
		bitmapData.unlock();
	}

	public function beam(x:Int, y:Int, index:Int, palette:Palette) {
		bitmapData.setPixel32(x, y, palette.get(index).output);
	}
}
