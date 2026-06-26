extends RichTextLabel

@export var speed := 30.0

func _ready():
	var sb = get_v_scroll_bar()
	sb.modulate.a = 0.0
	sb.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta):
	get_v_scroll_bar().value += speed * delta
