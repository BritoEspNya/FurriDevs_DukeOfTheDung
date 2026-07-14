extends RichTextLabel

@export var speed := 30.0
var value = 0

func _ready():
	var sb = get_v_scroll_bar()
	sb.modulate.a = 0.0
	sb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sb.step = 0.001

func _process(delta):
	value += speed * delta
	get_v_scroll_bar().value = value
