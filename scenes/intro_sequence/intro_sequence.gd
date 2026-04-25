extends Control

## Data-driven intro screen sequencer.
##
## _SCREENS drives the entire sequence — no branching code needed.
## Add, remove, or reorder entries here to change the intro.
##
## Types:
##   "logo"  — centered image. Set "path" to the texture resource path.
##   "text"  — centered text. Use "text" for a raw string (no localization)
##              or "key" for a TranslationServer key (passed through tr()).
##
## "duration" is the auto-advance time in seconds. Omit it to use the default (5 s).
## Click / ui_accept advances to the next screen; ui_cancel (Escape) skips the whole sequence.

const _FADE_DURATION := 0.6

const _SCREENS: Array[Dictionary] = [
	{ "type": &"logo", "path": "res://assets/logos/thewitchescircle_logo.png",                  "duration": 4.0 },
	{ "type": &"logo", "path": "res://assets/logos/godot_logo_vertical_monochrome_dark.png",  "duration": 4.0 },
	# Raw string — no translation, displayed exactly as written.
	{ "type": &"text",
	  "text": "THIS IS A FICTIONAL WORK.\nNAMES, CHARACTERS, AND EVENTS ARE PRODUCTS OF THE AUTHOR'S IMAGINATION.\nANY RESEMBLANCE TO ACTUAL EVENTS OR PERSONS IS COINCIDENTAL.",
	  "duration": 7.0 },
	# Localization key — text comes from TranslationServer (locale/ui.csv).
	# "duration" omitted here to demonstrate the 5 s default.
	{ "type": &"text", "key": "INTRO_ATTRIBUTION", "icon": "res://assets/logos/dopros_logo.png" },
]

@onready var _content: Control              = $Content
@onready var _layout_logo: TextureRect      = $Content/LayoutLogo
@onready var _layout_text_box: Control      = $Content/LayoutTextBox
@onready var _text_icon: TextureRect        = $Content/LayoutTextBox/TextIcon
@onready var _text_body: Label             = $Content/LayoutTextBox/TextBody
@onready var _timer: Timer                  = $Timer

var _index: int = 0
var _transitioning: bool = false


func _ready() -> void:
	_show_screen(_index)


func _show_screen(index: int) -> void:
	if index >= _SCREENS.size():
		get_tree().change_scene_to_file("res://scenes/end_screen/end_screen.tscn")
		return

	var screen: Dictionary = _SCREENS[index]
	_transitioning = false

	if screen["type"] == &"logo":
		_layout_logo.texture = load(screen["path"])
		_layout_logo.visible = true
		_layout_text_box.visible = false
	else:
		var icon_path: String = screen.get("icon", "")
		_text_icon.texture = load(icon_path) if not icon_path.is_empty() else null
		_text_icon.visible = not icon_path.is_empty()
		# "key" → go through TranslationServer; "text" → raw string as-is.
		_text_body.text = tr(screen["key"]) if screen.has("key") else screen.get("text", "")
		_layout_logo.visible = false
		_layout_text_box.visible = true

	_content.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_content, "modulate:a", 1.0, _FADE_DURATION)

	_timer.wait_time = screen.get("duration", 5.0)
	_timer.start()


func _advance() -> void:
	if _transitioning:
		return
	_transitioning = true
	_timer.stop()
	var tween := create_tween()
	tween.tween_property(_content, "modulate:a", 0.0, _FADE_DURATION)
	tween.tween_callback(func() -> void:
		_index += 1
		_show_screen(_index)
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file("res://scenes/end_screen/end_screen.tscn")
	elif event.is_action_pressed("ui_accept") \
			or (event is InputEventMouseButton and (event as InputEventMouseButton).pressed):
		get_viewport().set_input_as_handled()
		_advance()


func _on_timer_timeout() -> void:
	_advance()
