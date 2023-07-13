package res.openfl;

import res.audio.AudioChannel;
import res.audio.IAudioBuffer;

class AudioMixer extends res.audio.AudioMixer {
	public function new() {}

	public function createAudioChannel(buffer:IAudioBuffer, loop:Bool):AudioChannel {
		return new res.openfl.AudioChannel(cast buffer, loop);
	}
}
