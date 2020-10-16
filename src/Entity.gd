extends KinematicBody2D

class_name Entity

var health : int setget _set_health
var armor : int
var capabilities = {}
var currentAction setget _set_current_action
var type
var isSelectable = true
var team : int
var isSelected setget _set_is_selected
var isDead = false

var level

var defaultTargetAction = "Move"

var infoBaloon
var actionsInfo
var actionProgressInfo

const LOOK_LEFT = -1
const LOOK_RIGHT = 1

const TYPE_UNIT = "unit"
const TYPE_BUILDING = "building"

const TEAM_PLAYER = 1
const TEAM_ENEMY = 2

signal action_changed(oldAction, newAction)
signal animation_signal(signalName)
signal capability_added(capability)

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
			
	connect("action_changed", self, "_on_current_action_changed")
	connect("capability_added", self, "_on_capability_added")
	
func _physics_process(delta):
	for capName in capabilities:
		var cap = capabilities[capName]
		if !isDead || cap.activeOnDeadEntity:
			cap.process(delta)
		
	z_index = position.y

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
		
func has_capability(capabilityName):
	return capabilities.has(capabilityName)

func perform_action(actionName, args, internal = false):
	if capabilities.has(actionName):
		var cap = capabilities[actionName]
		if !internal:
			if currentAction:
				currentAction.cancel()
			self.currentAction = cap
			
		return cap.perform(args, internal)
	else:
		# self.currentAction = null
		return false
	
func perform_action_by_hotkey(hotkey, args, internal = false):
	for capName in capabilities:
		var cap = capabilities[capName]
		if cap.hotkey == hotkey:
			return cap.perform(args, internal)
			
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
	
	if type != TYPE_BUILDING:
		return
		
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

func queue_death():
	isDead = true
	if has_node("AnimationPlayer"):
		var animationPlayer = get_node("AnimationPlayer")
		if (animationPlayer as AnimationPlayer).has_animation("Death"):
			animationPlayer.seek(0, true)
			animationPlayer.stop()
			connect("animation_signal", self, "_on_animation_signal")
			animationPlayer.play("Death")
	
func _on_animation_signal(signalName):
	if signalName == "Death":
		queue_free()
	
func _set_health(value):
	health = value
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
