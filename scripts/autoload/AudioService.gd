extends Node

var music_volume := 0.8
var sound_volume := 0.9
var _sfx_player: AudioStreamPlayer = null

const SAMPLE_RATE := 22050.0
const DEFAULT_TONE_SECONDS := 0.05
const EVENT_FREQUENCIES := {
	&"spawn": 560.0,
	&"duplicate": 620.0,
	&"resize": 660.0,
	&"reset": 320.0,
	&"fan": 740.0,
	&"smash": 240.0,
	&"drag_release": 420.0,
}


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = SAMPLE_RATE
	generator.buffer_length = 0.08
	_sfx_player.stream = generator
	_sfx_player.volume_db = linear_to_db(clampf(sound_volume, 0.001, 1.0))
	add_child(_sfx_player)
	_sfx_player.play()


func apply_settings(next_music_volume: float, next_sound_volume: float) -> void:
	music_volume = next_music_volume
	sound_volume = next_sound_volume
	if _sfx_player != null:
		_sfx_player.volume_db = linear_to_db(clampf(sound_volume, 0.001, 1.0))


func play_feedback(event_name: StringName) -> void:
	if _sfx_player == null:
		return

	if not _sfx_player.playing:
		_sfx_player.play()

	var playback := _sfx_player.get_stream_playback()
	if playback == null or not (playback is AudioStreamGeneratorPlayback):
		return

	var stream_playback := playback as AudioStreamGeneratorPlayback
	var frequency: float = float(EVENT_FREQUENCIES.get(event_name, 520.0))
	var frame_count := int(SAMPLE_RATE * DEFAULT_TONE_SECONDS)
	var phase_step := TAU * frequency / SAMPLE_RATE
	var phase := 0.0
	for frame in range(frame_count):
		if stream_playback.get_frames_available() <= 0:
			break
		var envelope := 1.0 - (float(frame) / float(frame_count))
		var sample := sin(phase) * 0.22 * envelope
		stream_playback.push_frame(Vector2(sample, sample))
		phase += phase_step
