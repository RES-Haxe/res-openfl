package res.openfl;

import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.GameInputEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TextEvent;
import openfl.geom.Point;
import openfl.system.System;
import openfl.ui.GameInput;
import openfl.ui.GameInputControl;
import openfl.ui.GameInputDevice;
import res.CRT;
import res.audio.IAudioBuffer;
import res.audio.IAudioStream;
import res.input.ControllerButton;
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

		new GameInput().addEventListener(GameInputEvent.DEVICE_ADDED, (event) -> {
			for (i in 0...event.device.numControls) {
				final ctrl = event.device.getControlAt(i);

				ctrl.addEventListener(Event.CHANGE, (event) -> {
					if (!StringTools.startsWith(ctrl.id, 'AXIS_')) {
						final ctrlMap:Map<String, ControllerButton> = [
							// @formatter: off
							'BUTTON_0' => A,
							'BUTTON_1' => B,
							'BUTTON_2' => X,
							'BUTTON_3' => Y,
							'BUTTON_4' => SELECT,
							'BUTTON_6' => START,
							'BUTTON_11' => UP,
							'BUTTON_12' => DOWN,
							'BUTTON_13' => LEFT,
							'BUTTON_14' => RIGTH,
							// @formatter: on
						];

						final btn = ctrlMap[ctrl.id];

						if (btn != null) {
							if (ctrl.value == 1) {
								res.ctrl().press(btn);
							} else {
								res.ctrl().release(btn);
							}
						}
					}
				});
			}

			event.device.enabled = true;
		});

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

	override function shutdown() {
		System.exit(0);
	}
}
