## Debug helper: run one seed and print its Month Report lines of chosen kinds.
##   godot --headless --path . --script res://tools/debug_seed.gd -- --seed 1 --months 48 --kinds choir,death
extends SceneTree

const SimData := preload("res://sim/sim_data.gd")
const RoadGraph := preload("res://sim/road_graph.gd")
const World := preload("res://sim/world.gd")


func _init() -> void:
	var seed_n := 1
	var months := 48
	var kinds: PackedStringArray = []
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		match args[i]:
			"--seed": seed_n = int(args[i + 1])
			"--months": months = int(args[i + 1])
			"--kinds": kinds = args[i + 1].split(",")
	var data := SimData.new()
	data.load_all()
	var graph := RoadGraph.new()
	graph.build(data)
	var w := World.new()
	w.setup(data, graph, seed_n)
	for m in months:
		w.world_turn()
	for e in w.events:
		if kinds.is_empty() or kinds.has(e["kind"]):
			print("m%d %s: %s" % [e["m"], e["kind"], e["text"]])
	for h in w.history:
		if h["month"] % 6 == 0:
			print("m%d silenced=%d voices=%.0f reach=%s turning=%s leaning=%s" % [h["month"], h["silenced"], h["voices"], h["reach"], h["turning"], h["leaning"]])
	quit()
