extends Capability

class_name PrayCapability

var currentTarget
var isInsidePrayArea = false
var isPraying = false setget _set_is_praying
var animationPlayer
var delayTime = 0.0
var delayTimer = 0.0

var isMovingToTarget = false
var moveCap

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
		if moveCap && isMovingToTarget:
			moveCap.cancel()
		
		if currentTarget is Entity:
			if value:
				if ownerEntity.position.x > currentTarget.position.x:
					ownerEntity.set_look_direction(Entity.LOOK_LEFT)
				else:
					ownerEntity.set_look_direction(Entity.LOOK_RIGHT)
					
				if animationPlayer && animationPlayer.current_animation != "Pray":
					animationPlayer.stop(true)
					animationPlayer.play("Pray")
					
				currentTarget.emit_capability_signal(self, "new_prayer", {})
			else:
				if animationPlayer && animationPlayer.current_animation == "Pray":
					animationPlayer.seek(0, true)
					animationPlayer.stop(true)
					
				currentTarget.emit_capability_signal(self, "prayer_left", {})
				
func _on_pray_area_entered(area, entered):
	var parent = area.get_parent()
	if parent is Entity && parent.team == ownerEntity.team:
		isInsidePrayArea = entered
		
	if ownerEntity.currentAction == self && isInsidePrayArea:
		if delayTime == 0:
			self.isPraying = true
		else:
			delayTimer = 0.0
	else:
		self.isPraying = false

func perform(args, internal = false):
	currentTarget = args["target"]
	if args.has("delay"):
		delayTime = args["delay"]
		
	delayTimer = 0.0
	
	if !internal:
		if ownerEntity.currentAction && ownerEntity.currentAction != self:
			ownerEntity.currentAction.cancel()
		ownerEntity.currentAction = self
	
#	if !internal && ownerEntity.has_node("ConfirmSound") && ownerEntity.team == Entity.TEAM_PLAYER:
#		if !ownerEntity.get_node("ConfirmSound").playing:
#			ownerEntity.get_node("ConfirmSound").play()
			
	if isInsidePrayArea && delayTime == 0.0:
		self.isPraying = true
	
	return true
	
func cancel():
	self.isPraying = false
	currentTarget = null
	if moveCap && isMovingToTarget:
		moveCap.cancel()
		
	isMovingToTarget = false

func process(delta):
	if ownerEntity.currentAction != self:
		return
			
	if currentTarget is Entity && currentTarget.isDead:
		cancel()
		return

	if !moveCap:
		moveCap = ownerEntity.get_capability("Move")
			
	if !isInsidePrayArea:
		isMovingToTarget = true
		if moveCap && (typeof(moveCap.currentTarget) != typeof(currentTarget) || moveCap.currentTarget != currentTarget):
			moveCap.perform({"target": currentTarget}, true)
	else:
		if delayTime > 0 && delayTimer >= delayTime:
			delayTimer = 0.0
			if isMovingToTarget:
				isMovingToTarget = false
				moveCap.cancel()
			self.isPraying = true
		else:
			delayTimer += delta
