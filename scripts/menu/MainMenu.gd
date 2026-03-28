extends Control

@onready var play_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PlayButton
@onready var settings_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/QuitButton
@onready var settings_overlay: Control = $SettingsOverlay
@onready var music_slider: HSlider = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/MusicRow/MusicSlider
@onready var sound_slider: HSlider = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/SoundRow/SoundSlider
@onready var music_value_label: Label = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/MusicRow/MusicValueLabel
@onready var sound_value_label: Label = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/SoundRow/SoundValueLabel
@onready var reset_tutorial_button: Button = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/TutorialRow/ResetTutorialButton
@onready var close_settings_button: Button = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/SettingsButtonsRow/CloseSettingsButton
@onready var settings_status_label: Label = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/SettingsStatusLabel


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	music_slider.value_changed.connect(_on_music_slider_changed)
	sound_slider.value_changed.connect(_on_sound_slider_changed)
	reset_tutorial_button.pressed.connect(_on_reset_tutorial_pressed)
	close_settings_button.pressed.connect(_on_close_settings_pressed)
	_load_settings_ui()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/Sandbox.tscn")


func _on_settings_pressed() -> void:
	settings_status_label.text = ""
	_set_settings_overlay_visible(true)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_music_slider_changed(_value: float) -> void:
	_refresh_slider_labels()
	_apply_and_persist_audio_settings()


func _on_sound_slider_changed(_value: float) -> void:
	_refresh_slider_labels()
	_apply_and_persist_audio_settings()


func _on_reset_tutorial_pressed() -> void:
	GameState.set_tutorial_dismissed(false)
	settings_status_label.text = "Tutorial reset. It will appear in the sandbox."


func _on_close_settings_pressed() -> void:
	_set_settings_overlay_visible(false)


func _load_settings_ui() -> void:
	var persisted_state := SaveService.get_state()
	var music_volume := clampf(float(persisted_state.get("music_volume", AudioService.music_volume)), 0.0, 1.0)
	var sound_volume := clampf(float(persisted_state.get("sound_volume", AudioService.sound_volume)), 0.0, 1.0)
	music_slider.set_value_no_signal(music_volume)
	sound_slider.set_value_no_signal(sound_volume)
	AudioService.apply_settings(music_volume, sound_volume)
	_refresh_slider_labels()
	_set_settings_overlay_visible(false)


func _refresh_slider_labels() -> void:
	music_value_label.text = "%d%%" % int(round(music_slider.value * 100.0))
	sound_value_label.text = "%d%%" % int(round(sound_slider.value * 100.0))


func _apply_and_persist_audio_settings() -> void:
	var music_volume := clampf(float(music_slider.value), 0.0, 1.0)
	var sound_volume := clampf(float(sound_slider.value), 0.0, 1.0)
	AudioService.apply_settings(music_volume, sound_volume)
	SaveService.update_state({
		"music_volume": music_volume,
		"sound_volume": sound_volume,
	})


func _set_settings_overlay_visible(is_visible: bool) -> void:
	settings_overlay.visible = is_visible
