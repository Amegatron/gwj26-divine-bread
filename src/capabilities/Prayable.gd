extends Capability

class_name PrayableCapability

var maxPrayers = 0
var currentPrayers = 0 setget _set_prayers
var prayerBonus = 0.4

signal prayers_changed(oldValue, newValue)

func _init():
	capabilityName = "Prayable"
	isInHotBar = false
	maxPrayers = 16

func _set_owner(value):
	._set_owner(value)
	ownerEntity.connect("custom_capability_signal", self, "_on_capability_signal")

func _set_prayers(value):
	var oldValue = currentPrayers
	currentPrayers = value
	if oldValue != value:
		emit_signal("prayers_changed", oldValue, value)
		
func _on_capability_signal(capability, signalName, args):
	match signalName:
		"new_prayer":
			self.currentPrayers += 1
		"prayer_left":
			self.currentPrayers -= 1
