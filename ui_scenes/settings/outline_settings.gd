extends VBoxContainer


#var enable_outline: bool = false
#var outline_color: Color = Color.WHITE
#var outline_width: int = 6
#signal outline_updated

@onready var check_box: CheckBox = $EnableOutline/CheckBox
@onready var color_picker_button: ColorPickerButton = $EnableOutline/ColorPickerButton
@onready var outline_width_slider: LabelControlSlider = $OutlineWidth/OutlineWidthSlider



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.outline_updated.connect(_on_outlines_updated)


var _outlines_created: bool = false
func _on_outlines_updated() -> void:
	# Update settings vals
	check_box.button_pressed = Global.enable_outline
	color_picker_button.color = Global.outline_color
	outline_width_slider.value = Global.outline_width
	
	if _outlines_created != Global.enable_outline:
		_outlines_created = Global.enable_outline
		_create_destroy_outlines()


func _create_destroy_outlines() -> void:
	# make or destroy outlines on each sprite.
	if Global.enable_outline:
		# Create an outline sprite for each sprite object.
		for sprite_object: SpriteObject in get_tree().get_nodes_in_group(SpriteObject.SPRITE_OBJECT_GROUP):
			if not sprite_object.sprite.has_node("SpriteOutline"):
				var outline: SpriteOutline = SpriteOutline.new()
				outline.name = "SpriteOutline"
				sprite_object.sprite.add_child(outline)
			assert(sprite_object.sprite.has_node("SpriteOutline"))
	else:
		# Outlines are disabled, we can remove SpriteOutlines from tree.
		for outline: SpriteOutline in get_tree().get_nodes_in_group(SpriteOutline.SPRITE_OUTLINE_GROUP):
			outline.queue_free()



func _on_color_picker_button_color_changed(color: Color) -> void:
	Global.outline_color = color
	Saving.settings["outline_color"] = var_to_str(color)
	Global.outline_updated.emit()


func _on_outline_width_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Global.outline_width = int(outline_width_slider.value)
		Saving.settings["outline_width"] = Global.outline_width
		Global.outline_updated.emit()


func _on_check_box_toggled(toggled_on: bool) -> void:
	Global.enable_outline = toggled_on
	Saving.settings["enable_outline"] = toggled_on
	Global.outline_updated.emit()
