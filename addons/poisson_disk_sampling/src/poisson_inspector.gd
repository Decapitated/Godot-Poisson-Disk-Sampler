extends EditorInspectorPlugin

const poisson_control = preload("PoissonControl.res")

var editor_interface: EditorInterface

func _can_handle(object):
	return object is PoissonDiskSampler2D

func _parse_begin(object):
	var poisson2D = object as PoissonDiskSampler2D
	var temp_control = poisson_control.instantiate()

	# Bind generator button.
	var generate_button = temp_control.find_child("GenerateButton") as Button
	generate_button.pressed.connect(_generate_button_pressed.bind(poisson2D))

	# Bind clear button.
	var clear_button = temp_control.find_child("ClearButton") as Button
	clear_button.pressed.connect(_clear_button_pressed.bind(poisson2D))

	# Add control.
	add_custom_control(temp_control)

func _generate_button_pressed(poisson2D: PoissonDiskSampler2D):
	poisson2D.generate()

func _clear_button_pressed(poisson2D: PoissonDiskSampler2D):
	poisson2D.clear()