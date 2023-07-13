package res.openfl;

import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.geom.Point;
import openfl.ui.GameInput;
import res.audio.IAudioBuffer;
import res.audio.IAudioStream;
import res.display.CRT;
import res.storage.Storage;

class BIOS extends res.bios.BIOS {
	public var bitmap:Bitmap;

	var container:DisplayObjectContainer;
	var res:RES;
	var autosize:Bool;
	var lastTime:Int;

	public function new(container:DisplayObjectContainer, autosize:Bool = true) {
		super('OpenFL');
		this.container = container;
		this.container.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		this.autosize = autosize;
	}

	function onEnterFrame(e:Event) {
		if (res != null) {
			var currentTime = Lib.getTimer();

			res.update((currentTime - lastTime) / 1000);
			res.render();

			lastTime = currentTime;
		}
	}

	function resize() {
		if (bitmap != null) {
			final s = Math.min(container.stage.stageWidth / bitmap.bitmapData.width, container.stage.stageHeight / bitmap.bitmapData.height);

			bitmap.width = bitmap.bitmapData.width * s;
			bitmap.height = bitmap.bitmapData.height * s;

			bitmap.x = (container.stage.stageWidth - bitmap.width) / 2;
			bitmap.y = (container.stage.stageHeight - bitmap.height) / 2;
		}
	}

	public function connect(res:RES) {
		this.res = res;

		container.stage.addEventListener(KeyboardEvent.KEY_DOWN, (event:KeyboardEvent) -> {
			res.keyboard.keyDown(event.keyCode);
		});

		container.stage.addEventListener(TextEvent.TEXT_INPUT, (event:TextEvent) -> {
			res.keyboard.input(event.text);
		});

		container.stage.addEventListener(KeyboardEvent.KEY_UP, (event:KeyboardEvent) -> {
			res.keyboard.keyUp(event.keyCode);
		});

		container.stage.addEventListener(MouseEvent.MOUSE_MOVE, (event) -> {
			if (bitmap != null) {
				final p = bitmap.globalToLocal(new Point(event.localX, event.localY));
				res.mouse.moveTo(Std.int(p.x), Std.int(p.y));
			}
		});

		container.stage.addEventListener(MouseEvent.MOUSE_DOWN, (event) -> {
			if (bitmap != null) {
				final p = bitmap.globalToLocal(new Point(event.localX, event.localY));
				res.mouse.push(LEFT, Std.int(p.x), Std.int(p.y));
			}
		});

		container.stage.addEventListener(MouseEvent.MOUSE_UP, (event) -> {
			if (bitmap != null) {
				final p = bitmap.globalToLocal(new Point(event.localX, event.localY));
				res.mouse.release(LEFT, Std.int(p.x), Std.int(p.y));
			}
		});

		if (GameInput.isSupported) {}

		if (autosize) {
			container.stage.addEventListener(Event.RESIZE, (_) -> {
				resize();
			});

			resize();
		}

		lastTime = Lib.getTimer();
	}

	public function createAudioBuffer(audioStream:IAudioStream):IAudioBuffer {
		return new AudioBuffer(audioStream);
	}

	public function createAudioMixer():res.audio.AudioMixer {
		return new AudioMixer();
	}

	public function createStorage():Storage {
		return new Storage();
	}

	public function createCRT(width:Int, height:Int):CRT {
		final bitmapData = new BitmapData(width, height, false);
		bitmap = new Bitmap(bitmapData);
		container.addChild(bitmap);
		return new res.openfl.CRT(bitmapData);
	}

	public function startup() {}
}
