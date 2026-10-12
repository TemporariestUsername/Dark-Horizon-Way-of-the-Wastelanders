## Evaluates ambition "when" strings from factions.json, e.g.
##   "walls(helena) >= 1"
##   "leans(siege) == lighthouse and leans(arch) == lighthouse"
##   "count(debtors on the Sixty-Five) >= 3"
## Each clause is `call op value`; clauses are joined by " and ".
## The World supplies the functions through query(name, args).
extends RefCounted

static var _re_clause: RegEx


static func _clause_re() -> RegEx:
	if _re_clause == null:
		_re_clause = RegEx.new()
		_re_clause.compile("^\\s*([a-z_0-9]+)(?:\\(([^)]*)\\))?\\s*(>=|<=|==|!=|<|>)?\\s*([^\\s]+)?\\s*$")
	return _re_clause


static func evaluate(expr: String, world) -> bool:
	for clause in expr.split(" and "):
		if not _eval_clause(clause, world):
			return false
	return true


## Holds and factions named in a condition, so the AI can treat them as targets.
static func mentioned_holds(expr: String, hold_ids: Dictionary) -> Array:
	var out: Array = []
	var words := expr.replace("(", " ").replace(")", " ").replace(",", " ").split(" ", false)
	for w in words:
		if hold_ids.has(w) and not out.has(w):
			out.append(w)
	return out


static func _eval_clause(clause: String, world) -> bool:
	var m := _clause_re().search(clause.strip_edges())
	assert(m != null, "cannot parse condition clause: " + clause)
	var fname := m.get_string(1)
	var args: Array = []
	if m.get_string(2) != "":
		for a in m.get_string(2).split(","):
			args.append(a.strip_edges())
	var lhs: Variant = world.query(fname, args)
	var op := m.get_string(3)
	if op == "":
		return bool(lhs)
	var rhs_s := m.get_string(4)
	var rhs: Variant = float(rhs_s) if rhs_s.is_valid_float() else rhs_s
	if rhs is float:
		var l := float(lhs)
		match op:
			">=": return l >= rhs
			"<=": return l <= rhs
			">": return l > rhs
			"<": return l < rhs
			"==": return is_equal_approx(l, rhs)
			"!=": return not is_equal_approx(l, rhs)
	else:
		match op:
			"==": return str(lhs) == rhs
			"!=": return str(lhs) != rhs
	assert(false, "bad operator in clause: " + clause)
	return false
