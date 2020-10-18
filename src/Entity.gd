extends KinematicBody2D

class_name Entity

# TODO: move some parameters (health, etc) to separate Capabilities
export var maxHealth : int
var health : int setget _set_health
var armor : int
var capabilities = {}
var currentAction setget _set_current_action
var type
var isSelectable = true
export var team : int
var isSelected setget _set_is_selected
var isDead = false setget _set_is_dead
var houseCapacityCost setget , _get_house_cost

var level

var defaultTargetAction = "Move"

var infoBaloon
var actionsInfo
var actionProgressInfo

const LOOK_LEFT = -1
const LOOK_RIGHT = 1

const TYPE_UNIT = "unit"
const TYPE_BUILDING = "building"
const TYPE_PROJECTILE = "projectile"

const TEAM_PLAYER = 1
const TEAM_ENEMY = 2

signal action_changed(oldAction, newAction)
signal animation_signal(signalName)
signal capability_added(capability)
signal capability_removed(capabilityName)
signal health_changed(oldHealth, newHealth)
signal died
signal action_performed(capability, args, result)
signal custom_capability_signal(capability, signalName, args)

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = position.y
	
	if has_node("BaloonPosition"):
		var baloonPos = get_node("BaloonPosition")
		if baloonPos:
			infoBaloon = _create_info_baloon()
			baloonPos.add_child(infoBaloon)
			infoBaloon.visible = false
			
			actionsInfo = _create_actions_info()
			actionProgressInfo = _create_progress_info()
			infoBaloon.set_baloon_content(actionsInfo)
			
	if has_node("HealthBar"):
		get_node("HealthBar").visible = false
				
	connect("action_changed", self, "_on_current_action_changed")
	connect("capability_added", self, "_on_capability_added")
	connect("capability_removed", self, "_on_capability_removed")
	
func _process(delta):
	z_index = position.y

	if isSelected:
		pass
		
	for cap in capabilities.values():
		if !isDead || cap.activeOnDeadEntity:
			cap.process(delta)
	
func _physics_process(delta):
	for cap in capabilities.values():
		if !isDead || cap.activeOnDeadEntity:
			cap.process_physics(delta)

func get_capability(capabilityName):
	if capabilities.has(capabilityName):
		return capabilities[capabilityName]
	else:
		return null

func add_capability(capability):
	if !capabilities.has(capability.capabilityName):
		capability.ownerEntity = self
		capabilities[capability.capabilityName] = capability
		emit_signal("capability_added", capability)
	
func remove_capability(capabilityName):
	if capabilities.has(capabilityName):
		capabilities.erase(capabilityName)
		emit_signal("capability_removed", capabilityName)
		
func has_capability(capabilityName):
	return capabilities.has(capabilityName)

func perform_action(actionName, args, internal = false):
	if capabilities.has(actionName):
		var cap = capabilities[actionName]
		if isDead && !cap.activeOnDeadEntity:
			return false
			
		if level.gameManager.are_requirements_met(cap.requirements, team):
			# TODO: check that all caps return true or false
			var result = cap.perform(args, internal)
			if result:
				level.gameManager.consume_requirements(cap.requirements, team)
				emit_signal("action_performed", cap, args, result)
				
			return result
	else:
		return false
	
func perform_action_by_hotkey(hotkey, args, internal = false):
	for capName in capabilities:
		var cap = capabilities[capName]
		if cap.hotkey == hotkey:
			return perform_action(capName, args, internal)
			
	return false

func set_current_action(capability):
	var oldAction = currentAction
	
	currentAction = capability
	
	if oldAction != currentAction:
		emit_signal("action_changed", oldAction, currentAction)

func set_look_direction(dir):
	match dir:
		LOOK_LEFT:
			$Sprites.scale.x = 1
		LOOK_RIGHT:
			$Sprites.scale.x = -1

func _set_is_selected(value):
	isSelected = value
			
	if infoBaloon:
		if value:
			if !currentAction:
				if actionsInfo.capabilities.size() > 0:
					infoBaloon.visible = true
				else:
					infoBaloon.visible = false
			else:
				infoBaloon.visible = true
		else:
			infoBaloon.visible = false
		
	if has_node("HealthBar"):
		get_node("HealthBar").visible = value

func queue_death():
	self.isDead = true
	if has_node("AnimationPlayer"):
		var animationPlayer = get_node("AnimationPlayer")
		if (animationPlayer as AnimationPlayer).has_animation("Death"):
			animationPlayer.seek(0, true)
			animationPlayer.stop()
			connect("animation_signal", self, "_on_animation_signal")
			animationPlayer.play("Death")
			return
	queue_free()
	
func _on_animation_signal(signalName):
	if signalName == "Death":
		queue_free()
	
func _set_health(value):
	var oldHealth = health
	health = value

	if oldHealth != value:
		emit_signal("health_changed", oldHealth, value)	

	if health <= 0:
		health = 0
		queue_death()

func _create_info_baloon():
	var baloon = load("res://scenes/ui/Baloon.tscn").instance()
	return baloon
	
func _create_actions_info():
	var actionsInfo = load("res://scenes/ui/BaloonActionsInfo.tscn").instance()
	for capName in capabilities:
		var cap = get_capability(capName)
		if cap.hotkey:
			actionsInfo.add_capability(cap)
			
	return actionsInfo

func _create_progress_info():
	var progressInfo = load("res://scenes/ui/ProgressInfo.tscn").instance()
	return progressInfo
	
func _set_current_action(value):
	var prevAction = currentAction
	if prevAction != value:
		currentAction = value
		if prevAction:
			prevAction.cancel()
		emit_signal("action_changed", prevAction, value)

func _on_current_action_changed(oldValue, newValue):
	if infoBaloon:
		if newValue is ProgressBaseCapability:
			actionProgressInfo.trackedCapability = newValue
			infoBaloon.set_baloon_content(actionProgressInfo)
		else:
			infoBaloon.set_baloon_content(actionsInfo)

func _on_capability_added(capability):
	if actionsInfo && capability.hotkey:
		actionsInfo.add_capability(capability)

func _set_is_dead(value):
	isDead = value
	if isDead:
		emit_signal("died")

func _get_house_cost():
	return houseCapacityCost

func _on_capability_removed(capabilityName):
	if actionsInfo:
		actionsInfo.remove_capability(capabilityName)

	if actionsInfo.capabilities.size() == 0:
		infoBaloon.visible = false

func emit_capability_signal(capability, signalName, args):
	emit_signal("custom_capability_signal", capability, signalName, args)
