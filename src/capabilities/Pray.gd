extends Capability

class_name PrayCapability

var currentTarget
var isInsidePrayArea = false
var isPraying = false setget _set_is_praying
var animationPlayer

func _init():
	capabilityName = "Pray"
	hotkey = KEY_P
	isInHotBar = true
	isTargeted = true
	
func _set_owner(value):
	._set_owner(value)
	if ownerEntity.has_node("PrayerArea"):
		ownerEntity.get_node("PrayerArea").connect("area_entered", self, "_on_pray_area_entered", [true])
		ownerEntity.get_node("PrayerArea").connect("area_exited", self, "_on_pray_area_entered", [false])
		
	if ownerEntity.has_node("AnimationPlayer") && ownerEntity.get_node("AnimationPlayer").has_animation("Pray"):
		animationPlayer = ownerEntity.get_node("AnimationPlayer")

func _set_is_praying(value):
	var oldValue = isPraying
	isPraying = value
	if oldValue != value:
		ownerEntity.emit_capability_signal(self, "praying", {"praying": value})
		var moveCap = ownerEntity.get_capability("Move")
		moveCap.cancel()
		
		if currentTarget is Entity:
			if value:
				if ownerEntity.position.x > currentTarget.position.x:
					ownerEntity.set_look_direction(Entity.LOOK_LEFT)
				else:
					ownerEntity.set_look_direction(Entity.LOOK_RIGHT)
					
				if animationPlayer:
					if animationPlayer.current_animation != "Pray":
						animationPlayer.seek(0, true)
						animationPlayer.play("Pray")
				currentTarget.emit_capability_signal(self, "new_prayer", {})
			else:
				if animationPlayer:
					animationPlayer.seek(0, true)
					animationPlayer.stop()
					
				currentTarget.emit_capability_signal(self, "prayer_left", {})
				
func _on_pray_area_entered(area, entered):
	var parent = area.get_parent()
	if parent is Entity && parent.team == ownerEntity.team:
		isInsidePrayArea = entered
		
	if ownerEntity.currentAction == self && isInsidePrayArea:
		self.isPraying = true
	else:
		self.isPraying = false

func perform(args, internal = false):
	currentTarget = args["target"]
	
	if !internal:
		ownerEntity.currentAction = self
	
	if !internal && ownerEntity.has_node("ConfirmSound") && ownerEntity.team == Entity.TEAM_PLAYER:
		if !ownerEntity.get_node("ConfirmSound").playing:
			ownerEntity.get_node("ConfirmSound").play()
			
	if isInsidePrayArea:
		self.isPraying = true
	
	return true
	
func cancel():
	self.isPraying = false
	currentTarget = null
	var moveCap = ownerEntity.get_capability("Move")
	if moveCap:
		moveCap.stuckAccumulator = 0.0

func process(delta):
	if ownerEntity.currentAction != self:
		return
			
	if currentTarget is Entity && currentTarget.isDead:
		currentTarget = null
		if ownerEntity.currentAction == self:
			ownerEntity.currentAction = null
			return

	var moveCap = ownerEntity.get_capability("Move")
	
	if moveCap.stuckAccumulator >= 1:
		moveCap.cancel()
		cancel()
	
	if !isInsidePrayArea:
		if typeof(moveCap.currentTarget) != typeof(currentTarget) || moveCap.currentTarget != currentTarget:
			moveCap.perform({"target": currentTarget}, true)
	else:
		moveCap.cancel()
