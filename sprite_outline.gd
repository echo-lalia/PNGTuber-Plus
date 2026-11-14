extends Sprite2D
class_name SpriteOutline


const SPRITE_OUTLINE_GROUP: StringName =  "SpriteOutlineGroup"
const CACHE_PATH: String = "user://.outline_sprite_cache/"
const MAX_CACHE_FILES: int = 300

var parent_sprite: Sprite2D
var outline_width: int = -1




func _enter_tree() -> void:
	add_to_group(SPRITE_OUTLINE_GROUP)
	parent_sprite = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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


## Set our sprite based on the the parent image, either loading from cache or generating from scratch.
func _make_outline_sprite() -> void:
	hframes = parent_sprite.hframes
	offset = parent_sprite.offset
	
	var raw_parent_image: Image = (parent_sprite.texture as ImageTexture).get_image()
	
	var img: Image
	if FileAccess.file_exists(_sprite_cache_path(raw_parent_image)):
		img = _load_cached_outline_sprite(raw_parent_image)
	else:
		img = _generate_new_outline_sprite(raw_parent_image)
	
	texture = ImageTexture.create_from_image(img)


## The filepath for our cache image.
func _sprite_cache_path(raw_parent_image: Image) -> String:
	return str(CACHE_PATH, outline_width, "-", hframes, "-", hash(parent_sprite.texture.resource_path), "-", hash(raw_parent_image.data), ".png")


## Handle making the cache directory, and cleaning it up if it gets too big.
func _outline_cache_housekeeping() -> void:
	DirAccess.make_dir_absolute(CACHE_PATH)
	var files := DirAccess.get_files_at(CACHE_PATH)
	if len(files) > MAX_CACHE_FILES:
		for file_path: String in files:
			var err: Error = DirAccess.remove_absolute(CACHE_PATH + file_path)
			if err != OK:
				print("Failed to remove cache file: ", error_string(err), file_path)


## Load the sprite sheet from cache instead of generating it from scratch.
func _load_cached_outline_sprite(raw_parent_image: Image) -> Image:
	return Image.load_from_file(_sprite_cache_path(raw_parent_image))


## Generate a new outline sprite sheet from the parent sprite sheet, saving the image to cache.
func _generate_new_outline_sprite(raw_parent_image: Image) -> Image:
	# Copy each frame of the source image with padding for the outline.
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
	
	_outline_cache_housekeeping()
	img.save_png(_sprite_cache_path(raw_parent_image))
	
	return img


func _process(_delta: float) -> void:
	frame = parent_sprite.frame
	self_modulate.a = parent_sprite.self_modulate.a
