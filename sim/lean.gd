## Lean: a hold's loyalty shares, summing to 100 (rules/lean.json).
## Shares are floats internally; "independent" is a share like any other.
extends RefCounted

const IND := "independent"


## Who the hold leans to (share >= threshold), or "" if contested. Silenced holds have no Lean.
static func leans(lean, threshold: float = 50.0) -> String:
	if lean == null:
		return ""
	var top := leader(lean)
	return top if top != "" and float(lean[top]) >= threshold else ""


static func leader(lean) -> String:
	if lean == null:
		return ""
	var best := ""
	var best_v := -1.0
	for k in lean:
		if float(lean[k]) > best_v:
			best = k
			best_v = float(lean[k])
	return best


static func share(lean, faction: String) -> float:
	if lean == null:
		return 0.0
	return float(lean.get(faction, 0.0))


## Move pts of Lean toward faction (pts may be negative: away from it, into independent).
## Positive points come from independent first, then from the largest other share.
## Returns the points actually moved.
static func add(lean: Dictionary, faction: String, pts: float) -> float:
	if pts == 0.0:
		return 0.0
	if pts < 0.0:
		var take: float = min(-pts, share(lean, faction))
		if take <= 0.0:
			return 0.0
		lean[faction] = share(lean, faction) - take
		lean[IND] = share(lean, IND) + take
		_tidy(lean)
		return -take
	var moved := 0.0
	var need := pts
	while need > 0.0001:
		var src := ""
		if faction != IND and share(lean, IND) > 0.0001:
			src = IND
		else:
			var best_v := 0.0001
			for k in lean:
				if k != faction and float(lean[k]) > best_v:
					src = k
					best_v = float(lean[k])
		if src == "":
			break
		var take: float = min(need, share(lean, src))
		lean[src] = share(lean, src) - take
		lean[faction] = share(lean, faction) + take
		moved += take
		need -= take
	_tidy(lean)
	return moved


## Conquest: the conqueror takes `conq` and the rest rescale to fill 100 - conq.
static func conquer(lean: Dictionary, faction: String, conq: float) -> void:
	var rest := 0.0
	for k in lean:
		if k != faction:
			rest += float(lean[k])
	var keys := lean.keys()
	for k in keys:
		if k == faction:
			continue
		lean[k] = (float(lean[k]) / rest) * (100.0 - conq) if rest > 0.0 else 0.0
	if rest <= 0.0:
		lean[IND] = 100.0 - conq
	lean[faction] = conq
	_tidy(lean)


## Remove a dead faction's shares into independent.
static func dissolve(lean: Dictionary, faction: String) -> void:
	if lean.has(faction):
		lean[IND] = share(lean, IND) + float(lean[faction])
		lean.erase(faction)


static func total(lean: Dictionary) -> float:
	var t := 0.0
	for k in lean:
		t += float(lean[k])
	return t


static func _tidy(lean: Dictionary) -> void:
	for k in lean.keys():
		if float(lean[k]) < 0.0001 and k != IND:
			lean.erase(k)
