extends Capability

class_name PrayableCapability

var maxPrayers = 0
var currentPrayers = 0 setget _set_prayers
var prayerBonus = 0.4

signal prayers_changed(oldValue, newValue)

func _init():
	capabilityName = "Prayable"
	isInHotBar = false
	maxPrayers = 20

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
			currentPrayers += 1
			print("New prayer!", currentPrayers)
		"prayer_left":
			currentPrayers -= 1
			print("Prayer left! ", currentPrayers)

func get_prayer_bonus():
	var affectivePrayers = min(maxPrayers, currentPrayers)
	return 1.0 + affectivePrayers * prayerBonus
