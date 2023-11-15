@tool
extends EditorPlugin

var poisson_inspector_plugin: EditorInspectorPlugin

func _enter_tree():
	# Create PoissionDiskSample class type.
	add_custom_type("PoissonDiskSampler", "Object", preload("src/poisson_disk_sampler.gd"), preload("poisson.png"))
	# Create PoissionDiskSample2D node type.
	add_custom_type("PoissonDiskSampler2D", "Node2D", preload("src/poisson_disk_sampler_node.gd"), preload("poisson.png"))
	# Add custom inspector plugin
	poisson_inspector_plugin = preload("src/poisson_inspector.gd").new()
	add_inspector_plugin(poisson_inspector_plugin)

func _exit_tree():
	remove_inspector_plugin(poisson_inspector_plugin)
	remove_custom_type("PoissonDiskSample2D")
	remove_custom_type("PoissonDiskSample")
