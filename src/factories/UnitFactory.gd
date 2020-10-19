extends Object

class_name UnitFactory

static func createUnitByName(name, team):
	match name:
		"Clubman":
			return createClubman(team)
		"StoneMaster":
			return createStoneMaster(team)

static func createClubman(team):
	var entity = load("res://scenes/Clubman.tscn").instance()
	entity.team = team
	if team == Entity.TEAM_ENEMY:
		var sprites = entity.get_node("Sprites")
		(sprites.get_node("Body") as Sprite).texture = load("res://images/caveman_body_emeny.png")
		(sprites.get_node("Head") as Sprite).texture = load("res://images/cavemane_head_enemy.png")
		(sprites.get_node("Arm") as Sprite).texture = load("res://images/arm_with_club_enemy.png")
	
	var cap = MoveCapability.new()
	entity.add_capability(cap)
	
	cap = TakeDamageCapability.new()
	entity.add_capability(cap)

	cap = AttackCapability.new()
	entity.add_capability(cap)
	
	cap = ReactOnAttackCapability.new()
	entity.add_capability(cap)
	
	cap = PrayCapability.new()
	entity.add_capability(cap)
	
	cap = PushableCapability.new()
	entity.add_capability(cap)
		
	return entity

static func createStoneMaster(team):
	var entity = load("res://scenes/StoneMaster.tscn").instance()
	entity.team = team
	if team == Entity.TEAM_ENEMY:
		var sprites = entity.get_node("Sprites")
		(sprites.get_node("Body") as Sprite).texture = load("res://images/stone_m_body_enemy.png")
		(sprites.get_node("Head") as Sprite).texture = load("res://images/stone_m_head_enemy.png")
		(sprites.get_node("Arm") as Sprite).texture = load("res://images/stone_m_arm_enemy.png")

	var cap = MoveCapability.new()
	entity.add_capability(cap)
	
	cap = TakeDamageCapability.new()
	entity.add_capability(cap)
	
	cap = RangedAttackCapability.new()
	entity.add_capability(cap)
	
	cap = ReactOnAttackCapability.new()
	entity.add_capability(cap)
	
	cap = PrayCapability.new()
	entity.add_capability(cap)
	
	cap = PushableCapability.new()
	entity.add_capability(cap)
	
	return entity
