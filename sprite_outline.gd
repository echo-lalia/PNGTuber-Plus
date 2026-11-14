extends Sprite2D
class_name SpriteOutline


const SPRITE_OUTLINE_GROUP: StringName =  "SpriteOutlineGroup"


var parent_sprite: Sprite2D
var outline_width: int = -1




func _enter_tree() -> void:
	add_to_group(SPRITE_OUTLINE_GROUP)
	parent_sprite = get_parent()




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Outline sprite added for: ", parent_sprite)
	z_index = -1000
	
	modulate = Global.outline_color
	outline_width = Global.outline_width
	_make_outline_sprite()
	Global.outline_updated.connect(_on_outline_updated)


func _on_outline_updated() -> void:
	if outline_width != Global.outline_width:
		outline_width = Global.outline_width
		_make_outline_sprite()
		
	modulate = Global.outline_color


func _make_outline_sprite() -> void:
	#print("Remaking outline sprite for ", parent_sprite.name, "...")
	#print("Parent image type: ", (parent_sprite.texture as ImageTexture).get_image().data["format"])
	
	# Copy each frame of the source image with padding for the outline.
	var raw_parent_image: Image = (parent_sprite.texture as ImageTexture).get_image()
	
	@warning_ignore("integer_division")
	var parent_tex_width: int = raw_parent_image.get_width() / parent_sprite.hframes
	var parent_tex_height: int = raw_parent_image.get_height()

	var modified_parent_image: Image = Image.create_empty(parent_tex_width*parent_sprite.hframes + outline_width*2*parent_sprite.hframes, parent_tex_height + outline_width*2, false, Image.FORMAT_RGBA8)
	for i in parent_sprite.hframes:
		modified_parent_image.blit_rect(
			raw_parent_image,
			Rect2i(i * parent_tex_width, 0, parent_tex_width, parent_tex_height),
			Vector2i(i * (parent_tex_width + outline_width*2) + outline_width, outline_width),
		)
	
	
	# Make the parent image pure white
	modified_parent_image.adjust_bcs(1000, 10, 0)
	
	var img: Image = modified_parent_image.duplicate()
	
	
	var outline_steps: int = 8 + (outline_width * 4)
	var rads_per_step: float = deg_to_rad(360.0 / outline_steps)
	for i in outline_steps:
		var position_offset: Vector2 = Vector2(outline_width, 0).rotated(rads_per_step * i)
		img.blend_rect(modified_parent_image, Rect2i(0, 0, modified_parent_image.get_width(), modified_parent_image.get_height()), position_offset)
	
	
	texture = ImageTexture.create_from_image(img)
	hframes = parent_sprite.hframes
	offset = parent_sprite.offset




func _process(_delta: float) -> void:
	frame = parent_sprite.frame
	self_modulate.a = parent_sprite.self_modulate.a
