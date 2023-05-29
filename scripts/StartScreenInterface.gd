extends CanvasLayer

@onready var gameScene = preload("res://levels/level_1.tscn")

@onready var fullscreenLabel = $MenuContainer/Options/MarginContainer/OptionsContainer/Display/VBoxContainer/WindowMode/MarginContainer2/Label
@onready var vsyncLabel = $MenuContainer/Options/MarginContainer/OptionsContainer/Display/VBoxContainer/Vsync/MarginContainer2/Label
@onready var masterVolume = $MenuContainer/Options/MarginContainer/OptionsContainer/Audio/VBoxContainer/MasterVolume/MarginContainer2/MasterVolumeSlider
@onready var soundVolume = $MenuContainer/Options/MarginContainer/OptionsContainer/Audio/VBoxContainer/SoundVolume/MarginContainer2/SoundVolumeSlider
@onready var musicVolume = $MenuContainer/Options/MarginContainer/OptionsContainer/Audio/VBoxContainer/MusicVolume/MarginContainer2/MusicVolumeSlider

const availableWindowModes = {
	0: "Windowed",
	2: "Maximized",
	3: "Fullscreen"
}

var selectedWindowMode = null
var selectedVsync = null

var selectedMaster = 1.0
var selectedSound = 1.0
var selectedMusic = 1.0

const availableVSyncModes = {
	0: "Disabled",
	1: "Enabled",
}

func _ready():
	showStartMenu()
	loadSelectedOptions()
	_on_display_options_pressed()


func _physics_process(_delta):
	update_options_ui()


func startGame():
	get_tree().change_scene_to_packed(gameScene)


func showStartMenu():
	$MenuContainer/StartMenu.show()
	$MenuContainer/HowToPlay.hide()
	$MenuContainer/Options.hide()


func howToPlay():
	$MenuContainer/StartMenu.hide()
	$MenuContainer/HowToPlay.show()
	$MenuContainer/Options.hide()


func options():
	$MenuContainer/StartMenu.hide()
	$MenuContainer/HowToPlay.hide()
	$MenuContainer/Options.show()


func quit():
	get_tree().quit()


func loadSelectedOptions():
	selectedWindowMode = SaveManager.game_options.window_mode
	selectedVsync = SaveManager.game_options.vsync
	selectedMaster = SaveManager.game_options.master_volume
	selectedSound = SaveManager.game_options.sound_volume
	selectedMusic = SaveManager.game_options.music_volume


func update_options_ui():
	fullscreenLabel.text = availableWindowModes.get(selectedWindowMode)
	vsyncLabel.text = availableVSyncModes.get(selectedVsync)
	masterVolume.value = selectedMaster
	soundVolume.value = selectedSound
	musicVolume.value = selectedMusic


func _on_display_options_pressed():
	$MenuContainer/Options/MarginContainer/OptionsContainer/Audio.hide()
	$MenuContainer/Options/MarginContainer/OptionsContainer/Display.show()


func _on_audio_options_pressed():
	$MenuContainer/Options/MarginContainer/OptionsContainer/Audio.show()
	$MenuContainer/Options/MarginContainer/OptionsContainer/Display.hide()


func next_cycle_option(opts: Dictionary, selected):
	var optionsKeys = opts.keys()
	for i in optionsKeys.size():
		if optionsKeys[i] == selected:
			return optionsKeys[0] if i == optionsKeys.size() - 1 else optionsKeys[i + 1]


func prev_cycle_option(opts: Dictionary, selected):
	var optionsKeys = opts.keys()
	for i in optionsKeys.size():
		if optionsKeys[i] == selected:
			return optionsKeys[optionsKeys.size() - 1] if i == 0 else optionsKeys[i - 1]


func _on_save_options_button_pressed():
	SaveManager.set_window_mode(selectedWindowMode)
	SaveManager.set_vsync_mode(selectedVsync)
	SaveManager.set_master_volume(selectedMaster)
	SaveManager.set_sound_volume(selectedSound)
	SaveManager.set_music_volume(selectedMusic)
	SaveManager.save_data()
	showStartMenu()


func _on_window_mode_prev_pressed():
	selectedWindowMode = prev_cycle_option(availableWindowModes, selectedWindowMode)


func _on_window_mode_next_pressed():
	selectedWindowMode = next_cycle_option(availableWindowModes, selectedWindowMode)


func _on_vsync_mode_prev_pressed():
	selectedVsync = prev_cycle_option(availableVSyncModes, selectedVsync)


func _on_vsync_mode_next_pressed():
	selectedVsync = next_cycle_option(availableVSyncModes, selectedVsync)


func _on_master_volume_slider_value_changed(value):
	selectedMaster = value


func _on_sound_volume_slider_value_changed(value):
	selectedSound = value


func _on_music_volume_slider_value_changed(value):
	selectedMusic = value