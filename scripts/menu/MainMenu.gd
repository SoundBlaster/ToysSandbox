extends Control

const PANEL_BASE_COLOR := Color("1a2742")
const LABEL_PRIMARY := Color("f5f8ff")
const LABEL_SECONDARY := Color("d4e2ff")

@onready var play_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PlayButton
@onready var settings_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/QuitButton
@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SubtitleLabel
@onready var main_panel: PanelContainer = $CenterContainer/PanelContainer
@onready var settings_overlay: Control = $SettingsOverlay
@onready var settings_panel: PanelContainer = $SettingsOverlay/PanelCenter/SettingsPanel
@onready var settings_title_label: Label = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/SettingsTitleLabel
@onready var music_label: Label = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/MusicRow/MusicLabel
@onready var sound_label: Label = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/SoundRow/SoundLabel
@onready var tutorial_label: Label = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/TutorialRow/TutorialLabel
@onready var unlimited_toys_label: Label = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/UnlimitedToysRow/UnlimitedToysLabel
@onready var music_slider: HSlider = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/MusicRow/MusicSlider
@onready var sound_slider: HSlider = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/SoundRow/SoundSlider
@onready var music_value_label: Label = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/MusicRow/MusicValueLabel
@onready var sound_value_label: Label = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/SoundRow/SoundValueLabel
@onready var reset_tutorial_button: Button = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/TutorialRow/ResetTutorialButton
@onready var unlimited_toys_button: CheckButton = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/UnlimitedToysRow/UnlimitedToysButton
@onready var close_settings_button: Button = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/SettingsButtonsRow/CloseSettingsButton
@onready var settings_status_label: Label = $SettingsOverlay/PanelCenter/SettingsPanel/SettingsMargin/SettingsVBox/SettingsStatusLabel


func _ready() -> void:
	_apply_visual_polish()
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	music_slider.value_changed.connect(_on_music_slider_changed)
	sound_slider.value_changed.connect(_on_sound_slider_changed)
	reset_tutorial_button.pressed.connect(_on_reset_tutorial_pressed)
	unlimited_toys_button.toggled.connect(_on_unlimited_toys_toggled)
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


func _on_unlimited_toys_toggled(is_toggled: bool) -> void:
	GameState.set_unlimited_toys_unlocked(is_toggled)
	_refresh_unlimited_toys_button()


func _load_settings_ui() -> void:
	var persisted_state := SaveService.get_state()
	var music_volume := clampf(float(persisted_state.get("music_volume", AudioService.music_volume)), 0.0, 1.0)
	var sound_volume := clampf(float(persisted_state.get("sound_volume", AudioService.sound_volume)), 0.0, 1.0)
	music_slider.set_value_no_signal(music_volume)
	sound_slider.set_value_no_signal(sound_volume)
	unlimited_toys_button.set_pressed_no_signal(bool(persisted_state.get("unlimited_toys_unlocked", false)))
	AudioService.apply_settings(music_volume, sound_volume)
	_refresh_slider_labels()
	_refresh_unlimited_toys_button()
	_set_settings_overlay_visible(false)


func _refresh_slider_labels() -> void:
	music_value_label.text = "%d%%" % int(round(music_slider.value * 100.0))
	sound_value_label.text = "%d%%" % int(round(sound_slider.value * 100.0))


func _refresh_unlimited_toys_button() -> void:
	unlimited_toys_button.text = "On" if unlimited_toys_button.button_pressed else "Off"


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


func _apply_visual_polish() -> void:
	main_panel.add_theme_stylebox_override("panel", _build_panel_style(Color("8ecbff"), 0.93))
	settings_panel.add_theme_stylebox_override("panel", _build_panel_style(Color("f4c486"), 0.95))

	title_label.add_theme_color_override("font_color", LABEL_PRIMARY)
	subtitle_label.add_theme_color_override("font_color", LABEL_SECONDARY)
	settings_title_label.add_theme_color_override("font_color", LABEL_PRIMARY)
	music_label.add_theme_color_override("font_color", LABEL_SECONDARY)
	sound_label.add_theme_color_override("font_color", LABEL_SECONDARY)
	tutorial_label.add_theme_color_override("font_color", LABEL_SECONDARY)
	unlimited_toys_label.add_theme_color_override("font_color", LABEL_SECONDARY)
	music_value_label.add_theme_color_override("font_color", LABEL_PRIMARY)
	sound_value_label.add_theme_color_override("font_color", LABEL_PRIMARY)
	settings_status_label.add_theme_color_override("font_color", LABEL_PRIMARY)

	_style_button(play_button, Color("57cb98"), 0.18)
	_style_button(settings_button, Color("5d8bff"), 0.16)
	_style_button(quit_button, Color("d07070"), 0.14)
	_style_button(reset_tutorial_button, Color("d79a5f"), 0.12)
	_style_button(unlimited_toys_button, Color("5bbd88"), 0.12)
	_style_button(close_settings_button, Color("6f8eff"), 0.12)


func _build_panel_style(accent: Color, alpha: float) -> StyleBoxFlat:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(PANEL_BASE_COLOR.r, PANEL_BASE_COLOR.g, PANEL_BASE_COLOR.b, alpha)
	panel_style.border_color = accent
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 18
	panel_style.corner_radius_top_right = 18
	panel_style.corner_radius_bottom_right = 18
	panel_style.corner_radius_bottom_left = 18
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.32)
	panel_style.shadow_size = 8
	return panel_style


func _style_button(button: Button, accent: Color, corner_radius: float) -> void:
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = accent.darkened(0.34)
	normal_style.border_color = accent.lightened(0.22)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = int(16.0 + corner_radius * 10.0)
	normal_style.corner_radius_top_right = int(16.0 + corner_radius * 10.0)
	normal_style.corner_radius_bottom_right = int(16.0 + corner_radius * 10.0)
	normal_style.corner_radius_bottom_left = int(16.0 + corner_radius * 10.0)
	normal_style.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	normal_style.shadow_size = 6

	var hover_style := normal_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = accent.darkened(0.2)
	hover_style.border_color = accent.lightened(0.3)

	var pressed_style := normal_style.duplicate() as StyleBoxFlat
	pressed_style.bg_color = accent.darkened(0.45)
	pressed_style.border_color = accent

	var disabled_style := normal_style.duplicate() as StyleBoxFlat
	disabled_style.bg_color = accent.darkened(0.58)
	disabled_style.border_color = accent.darkened(0.4)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("disabled", disabled_style)
	button.add_theme_color_override("font_color", Color("fff6e7"))
	button.add_theme_color_override("font_hover_color", Color("fffef7"))
	button.add_theme_color_override("font_pressed_color", Color("ffe9ca"))
