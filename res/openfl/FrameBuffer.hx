package res.openfl;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class FrameBuffer extends res.display.FrameBuffer {
	var _rect:Rectangle;

	public final bitmapData:BitmapData;

	public function new(width:Int, height:Int, palette:Palette) {
		super(width, height, palette.format([A, R, G, B]));

		_rect = new Rectangle(0, 0, width, height);

		bitmapData = new BitmapData(width, height, false, 0x0);
	}

	override public function beginFrame() {
		bitmapData.lock();
	}

	override public function clear(index:Int) {
		final color = _palette.get(index).output;
		bitmapData.fillRect(_rect, color);
	}

	override public function endFrame() {
		bitmapData.unlock();
	}

	function setPixel(x:Int, y:Int, color:Color32) {
		bitmapData.setPixel(x, y, color.output);
	}
}
