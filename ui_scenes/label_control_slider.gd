extends HSlider
class_name LabelControlSlider


@export var value_label: Label
@export var prefix: String = ""
@export var suffix: String = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value_changed.connect(_on_value_changed)
	_on_value_changed(value)


func _on_value_changed(val: float) -> void:
	if not value_label: return

	if is_equal_approx(val, int(val)):
		value_label.text = prefix + str(int(val)) + suffix
	else:
		value_label.text = prefix + ("%.1f" % val) + suffix
