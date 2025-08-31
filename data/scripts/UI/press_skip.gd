extends Button

@onready var dialogic = Dialogic
var skip_enabled = false

func _ready() -> void:
	if OS.has_feature("pc"):
		$f12.visible = true
	else:
		$f12.visible = false

	self.visible = false
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip") and skip_enabled:
		skip_dialogic()

func skip_dialogic():
	if skip_enabled and dialogic.current_timeline:
		dialogic.end_timeline()
		skip_enabled = false
		self.visible = false

func enable_skip():
	skip_enabled = true
	self.visible = true

func disable_skip():
	skip_enabled = false
	self.visible = false

func _on_dialogic_signal(argument: String):
	match argument:
		"skip":
			enable_skip()
		"disable_skip":
			disable_skip()

func _on_pressed() -> void:
	if skip_enabled:
		skip_dialogic()
