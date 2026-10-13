## Screenshots of the playable scenes, for checking placeholder art without a display.
##
##   xvfb-run -a -s "-screen 0 1280x800x24" godot --path . --rendering-driver opengl3 \
##       --script res://tools/capture.gd -- <shot> <out.png>
##
## Shots: menu, skirmish, skirmish_end, skirmish_result, road_war, road_war_end, road_war_result,
## journey, journey_card, journey_battle, journey_end. The *_result and journey_end shots play as a tester who
## presses Auto every turn, so the "how did that feel?" buttons show.
## Needs a renderer (not --headless).
extends SceneTree

const Game := preload("res://game/game.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		printerr("usage: -- <shot> <out.png>")
		quit(2)
		return
	var shot: String = args[0]
	load("res://game/playtest_log.gd").path = "user://capture/playtest_log.jsonl"   # not the real log
	Game.ensure_loaded()
	var scene_path := ""
	match shot:
		"menu":
			scene_path = "res://game/main_menu.tscn"
		"skirmish", "skirmish_end", "skirmish_result":
			Game.next = {"encounter": "raider_pack", "level": 2, "seed": 1}
			scene_path = "res://game/skirmish_scene.tscn"
		"road_war", "road_war_end", "road_war_result":
			Game.next = {"convoy": "teeth_raid", "level": 3, "seed": 1}
			scene_path = "res://game/road_war_scene.tscn"
		"journey", "journey_card", "journey_battle", "journey_end":
			Game.next = {"from": "lighthouse", "to": "dustwich", "level": 3, "seed": 1}
			Game.journey = null
			scene_path = "res://game/journey_scene.tscn"
		_:
			printerr("unknown shot " + shot)
			quit(2)
			return
	var scene: Node = load(scene_path).instantiate()
	root.add_child(scene)
	for i in 3:
		await process_frame
	match shot:
		"skirmish":
			# Play until the first party turn waits for input.
			for i in 50:
				if scene.waiting:
					break
				scene.step()
			scene.hover = scene.queue[0]["pos"] if not scene.queue.is_empty() else Vector2i(-1, -1)
		"skirmish_end":
			scene.auto_all = true
			for i in 2000:
				if scene.done:
					break
				scene.step()
		"road_war":
			for i in 50:
				if scene.waiting:
					break
				scene.step()
		"road_war_end":
			scene.auto_all = true
			for i in 2000:
				if scene.done:
					break
				scene.step()
		"skirmish_result", "road_war_result":
			for i in 3000:
				if scene.done:
					break
				if scene.waiting:
					scene._on_auto()
				else:
					scene.step()
		"journey_end":
			for i in 400:
				if scene.over:
					break
				var kind: String = scene.state["kind"]
				if kind == "card":
					scene._on_choice(scene.j.auto_choice(scene.state["event"], scene.state["chances"]))
				elif kind == "battle":
					scene._on_auto_resolve()
				else:
					scene.advance(true)
		"journey_battle":
			for i in 400:
				if scene.over or scene.state["kind"] == "battle":
					break
				if scene.state["kind"] == "card":
					scene._on_choice(scene.j.auto_choice(scene.state["event"], scene.state["chances"]))
				else:
					scene.advance(true)
		"journey_card":
			for i in 40:
				if scene.card.size() > 0 or scene.over:
					break
				scene.advance()
	if scene.has_method("_animate"):
		scene._animate(5.0)   # let slides finish and popups fade, as they would in play
	if "cam_x" in scene and not scene.waiting:
		scene.cam_x = scene._party_center()
	scene.queue_redraw()
	for i in 3:
		await process_frame
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(args[1])
	print("saved ", args[1], " ", img.get_size())
	quit(0)
