## The hold-to-hold road network (roads.json) with shortest paths.
## Distances are in road km. Winter-only edges (lake ice) are excluded from
## year-round distances; travel days account for road class.
extends RefCounted

var adj: Dictionary = {}        # hold id -> Array of edge dicts (each edge listed at both ends)
var dist: Dictionary = {}       # hold id -> {hold id: km}, year-round, all pairs
var prev_edge: Dictionary = {}  # hold id -> {hold id: edge used to reach it}, from that source
var km_per_day: Dictionary = {}
var fixed_days: Dictionary = {}
var _nearest_cache: Dictionary = {}


func build(data) -> void:
	km_per_day = data.time["travel"]["km_per_day"]
	fixed_days = data.time["travel"]["fixed_days"]
	for h in data.holds:
		adj[h["id"]] = []
	for e in data.edges:
		adj[e["a"]].append(e)
		adj[e["b"]].append(e)
	for h in data.holds:
		_dijkstra(h["id"])


static func other(e: Dictionary, from: String) -> String:
	return e["b"] if e["a"] == from else e["a"]


func _dijkstra(src: String) -> void:
	# 130 nodes: a simple O(V^2) Dijkstra is plenty and keeps iteration order deterministic.
	var d := {src: 0.0}
	var pe := {}
	var done := {}
	while true:
		var best := ""
		var best_d := INF
		for k in d:
			if not done.has(k) and d[k] < best_d:
				best = k
				best_d = d[k]
		if best == "":
			break
		done[best] = true
		for e in adj[best]:
			if e.get("season") == "winter":
				continue
			var u := other(e, best)
			var nd: float = best_d + float(e["km"])
			if nd < d.get(u, INF):
				d[u] = nd
				pe[u] = e
	dist[src] = d
	prev_edge[src] = pe


func km(a: String, b: String) -> float:
	return dist[a].get(b, INF)


## Holds within limit km of src by road (excluding src), as {id: km}.
func within(src: String, limit: float) -> Dictionary:
	var out := {}
	for k in dist[src]:
		if k != src and dist[src][k] <= limit:
			out[k] = dist[src][k]
	return out


## Holds within limit km of src (excluding src), nearest first. Cached: the graph never changes.
func nearest(src: String, limit: float) -> Array:
	var key := "%s|%d" % [src, int(limit)]
	if not _nearest_cache.has(key):
		var pairs: Array = []
		for k in dist[src]:
			if k != src and dist[src][k] <= limit:
				pairs.append([dist[src][k], k])
		pairs.sort_custom(func(x, y): return x[0] < y[0] or (x[0] == y[0] and x[1] < y[1]))
		_nearest_cache[key] = pairs.map(func(p): return p[1])
	return _nearest_cache[key]


## Edges on the shortest path from src to dst (in order from src).
func path_edges(src: String, dst: String) -> Array:
	var out: Array = []
	if not dist[src].has(dst):
		return out
	var cur := dst
	while cur != src:
		var e: Dictionary = prev_edge[src][cur]
		out.push_front(e)
		cur = other(e, cur)
	return out


## Road-adjacent holds (direct edges), year-round unless winter is true.
func neighbours(h: String, winter: bool = false) -> Array:
	var out: Array = []
	for e in adj[h]:
		if e.get("season") == "winter" and not winter:
			continue
		var u := other(e, h)
		if not out.has(u):
			out.append(u)
	return out


func edge_days(e: Dictionary) -> float:
	var kind: String = e["kind"]
	if fixed_days.has(kind):
		return fixed_days[kind]
	var days := 0.0
	for cls in e["mix"]:
		days += float(e["mix"][cls]) / float(km_per_day.get(cls, km_per_day["road"]))
	return days


func travel_days(src: String, dst: String) -> float:
	var days := 0.0
	for e in path_edges(src, dst):
		days += edge_days(e)
	return days
