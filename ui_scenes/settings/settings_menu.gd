extends Node2D

var awaitingCostumeInput = -1

var hasMouse = false


@export var color_picker_button: ColorPickerButton
@export var bounce_on_costume_check: CheckBox
@export var blink_speed_label: Label
@export var blink_speed: HSlider
@export var blink_chance_label: Label
@export var blink_chance: HSlider

@export var anti_aliasing_check_box: CheckBox
@export var bounce_force_label: Label
@export var bounce_gravity_label: Label
@export var typing_stop_delay_ms: Label
@export var bounce_force: HSlider
@export var bounce_gravity: HSlider
@export var input_finished_stop_ms: HSlider

func setvalues():
	
	color_picker_button.color = Global.backgroundColor
	if Global.backgroundColor == Color(0.0,0.0,0.0,0.0):
		color_picker_button.color = Color(1.0,1.0,1.0,1.0)
	
	
	bounce_force_label.text = str(Saving.settings["bounce"])
	bounce_force.value = Saving.settings["bounce"]
	bounce_gravity_label.text = str(Saving.settings["gravity"])
	bounce_gravity.value = Saving.settings["gravity"]
	typing_stop_delay_ms.text = str(Saving.settings["input_finished_threshold_ms"])
	input_finished_stop_ms.value = Saving.settings["input_finished_threshold_ms"]
	
	_on_check_box_toggled(Saving.settings["filtering"])
	
	blink_speed.value = int(1.0/Global.blinkSpeed)
	blink_speed_label.text = "blink speed: " + str(int(1.0/Global.blinkSpeed))
	
	blink_chance.value = Global.blinkChance
	blink_chance_label.text = "blink chance: 1 in " + str(Global.blinkChance) 
	
	
	bounce_on_costume_check.button_pressed = Global.main.bounceOnCostumeChange
	
	var costumeLabels = [$NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton1/Label,$NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton2/Label,$NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton3/Label,$NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton4/Label,$NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton5/Label,$NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton6/Label,$NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton7/Label,$NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton8/Label,$NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton9/Label,$NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton10/Label,]
	var tag = 1
	for label in costumeLabels:
		label.text = "costume " + str(tag) + " key: \"" + Global.main.costumeKeys[tag-1] + "\""
		tag += 1

	
func _on_color_picker_button_color_changed(color):
	get_viewport().transparent_bg = false
	RenderingServer.set_default_clear_color(color)
	Global.backgroundColor = color
	Saving.settings["backgroundColor"] = var_to_str(color)
	
	Global.pushUpdate("Background color set to CUSTOM COLOR.")


func _on_transparent_button_pressed():
	get_viewport().transparent_bg = true
	Global.backgroundColor = Color(0.0,0.0,0.0,0.0)
	Saving.settings["backgroundColor"] = var_to_str(Color(0.0,0.0,0.0,0.0))
	Global.pushUpdate("Background color set to TRANSPARENT.")


func _on_color_picker_button_picker_created():
	get_viewport().transparent_bg = false
	RenderingServer.set_default_clear_color(color_picker_button.color)


func _on_green_button_pressed():
	get_viewport().transparent_bg = false
	Global.backgroundColor = Color(0.0,1.0,0.0,1.0)
	Saving.settings["backgroundColor"] = var_to_str(Color(0.0,1.0,0.0,1.0))
	RenderingServer.set_default_clear_color(Color(0.0,1.0,0.0,1.0))
	
	Global.pushUpdate("Background color set to GREEN.")

func _on_blue_button_pressed():
	get_viewport().transparent_bg = false
	Global.backgroundColor = Color(0.0,0.0,1.0,1.0)
	Saving.settings["backgroundColor"] = var_to_str(Color(0.0,0.0,1.0,1.0))
	RenderingServer.set_default_clear_color(Color(0.0,0.0,1.0,1.0))
	
	Global.pushUpdate("Background color set to BLUE.")

func _on_magenta_button_pressed():
	get_viewport().transparent_bg = false
	Global.backgroundColor = Color(1.0,0.0,1.0,1.0)
	Saving.settings["backgroundColor"] = var_to_str(Color(1.0,0.0,1.0,1.0))
	RenderingServer.set_default_clear_color(Color(1.0,0.0,1.0,1.0))
	
	Global.pushUpdate("Background color set to MAGENTA.")



func _on_check_box_toggled(button_pressed):
	var new = 0
	if button_pressed:
		new = 2
	var nodes = get_tree().get_nodes_in_group("saved")
	for sprite in nodes:
		sprite.sprite.texture_filter = new
	Global.filtering = button_pressed
	Saving.settings["filtering"] = button_pressed
	anti_aliasing_check_box.button_pressed = button_pressed
	
	Global.pushUpdate("Texture filtering set to: " + str(button_pressed))



func _on_bounce_force_value_changed(value):
	bounce_force_label.text = str(value)
	Global.main.bounceSlider = value
	Saving.settings["bounce"] = value
	
	Global.pushUpdate("Bounce force value changed.")



func _on_bounce_gravity_value_changed(value):
	bounce_gravity_label.text = str(value)
	Global.main.bounceGravity = value
	Saving.settings["gravity"] = value
	
	Global.pushUpdate("Bounce gravity value changed.")



func _on_stop_ms_value_changed(value: float) -> void:
	typing_stop_delay_ms.text = str(int(value))
	Global.input_finished_threshold_ms = int(value)
	Global.pushUpdate("Bounce gravity value changed.")


func costumeButtonsPressed(label,id):
	label.text = "AWAITING INPUT"
	await Global.main.emptiedCapture
	awaitingCostumeInput = id - 1
	
	
	await Global.main.pressedKey
	label.text = "costume " + str(id) + " key: \"" + Global.main.costumeKeys[id - 1] + "\""
	await Global.main.emptiedCapture
	awaitingCostumeInput = -1


func _on_costume_button_1_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton1/Label
	costumeButtonsPressed(label,1)
func _on_costume_button_2_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton2/Label
	costumeButtonsPressed(label,2)
func _on_costume_button_3_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton3/Label
	costumeButtonsPressed(label,3)
func _on_costume_button_4_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton4/Label
	costumeButtonsPressed(label,4)
func _on_costume_button_5_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton5/Label
	costumeButtonsPressed(label,5)
func _on_costume_button_6_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton6/Label
	costumeButtonsPressed(label,6)
func _on_costume_button_7_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton7/Label
	costumeButtonsPressed(label,7)
func _on_costume_button_8_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton8/Label
	costumeButtonsPressed(label,8)
func _on_costume_button_9_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton9/Label
	costumeButtonsPressed(label,9)
func _on_costume_button_10_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton10/Label
	costumeButtonsPressed(label,10)



func _on_blink_speed_value_changed(value):
	if value == 0:
		Global.blinkSpeed = 0.0
		Saving.settings["blinkSpeed"] = 0.0
		blink_speed_label.text = "blink speed: 0"
		return
	Global.blinkSpeed = 1.0/float(value)
	Saving.settings["blinkSpeed"] = 1.0/float(value)
	blink_speed_label.text = "blink speed: " + str(value)



func _on_blink_chance_value_changed(value):
	Global.blinkChance = value
	Saving.settings["blinkChance"] = value
	blink_chance_label.text = "blink chance: 1 in " + str(value)


func _on_costume_check_toggled(button_pressed):
	Global.main.bounceOnCostumeChange = button_pressed
	Saving.settings["bounceOnCostumeChange"] = button_pressed


func _process(delta):
	var g = to_local(get_global_mouse_position())
	if g.x < 0 or g.y < 0 or g.x > $NinePatchRect.size.x or g.y > $NinePatchRect.size.y:
		hasMouse = false
	else:
		hasMouse = true

func deleteKey(label,id):
	Global.main.costumeKeys[id-1] = "null"
	label.text = "costume " + str(id) + " key: \"" + Global.main.costumeKeys[id-1] + "\""
	Global.pushUpdate("Deleted costume hotkey " + str(id) + ".")
	
func _on_delete_1_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton1/Label
	deleteKey(label,1)

func _on_delete_2_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton2/Label
	deleteKey(label,2)

func _on_delete_3_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton3/Label
	deleteKey(label,3)

func _on_delete_4_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton4/Label
	deleteKey(label,4)

func _on_delete_5_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton5/Label
	deleteKey(label,5)

func _on_delete_6_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton6/Label
	deleteKey(label,6)

func _on_delete_7_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton7/Label
	deleteKey(label,7)

func _on_delete_8_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton8/Label
	deleteKey(label,8)

func _on_delete_9_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton9/Label
	deleteKey(label,9)

func _on_delete_10_pressed():
	var label = $NinePatchRect/ScrollContainer/MarginContainer/VBoxContainer/CostumeInputs/VBoxContainer/costumeButton10/Label
	deleteKey(label,10)
