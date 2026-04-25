extends Control

@onready var _thanks_label: Label      = $CenterContainer/VBox/ThanksLabel
@onready var _attribution_label: Label = $CenterContainer/VBox/AttributionLabel
@onready var _quit_button: Button      = $CenterContainer/VBox/QuitButton


func _ready() -> void:
	_thanks_label.text = tr("THANKS_FOR_WATCHING")
	_attribution_label.text = tr("INTRO_ATTRIBUTION")
	_quit_button.text = tr("LEAVE")
	_quit_button.grab_focus()


func _on_quit_pressed() -> void:
	get_tree().quit()
