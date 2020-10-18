extends PanelContainer

class_name PrayersInfo

onready var counterLabel = $MarginContainer/VBoxContainer/HBoxContainer/Label setget , _get_counter_label
onready var bonusLabel = $MarginContainer/VBoxContainer/Label setget , _get_bonus_label

var prayableCapability setget _set_capability
var prayableBonusCapability setget _set_bonus_capability

func _get_counter_label():
	if !counterLabel:
		counterLabel = get_node("MarginContainer/VBoxContainer/HBoxContainer/Label")
		
	return counterLabel

func _get_bonus_label():
	if !bonusLabel:
		bonusLabel = get_node("MarginContainer/VBoxContainer/Label")
		
	return bonusLabel

func _set_bonus_capability(cap):
	if cap is PrayableBonusCapability:
		prayableBonusCapability = cap
		_update()

func _set_capability(cap):
	if cap is PrayableCapability:
		prayableCapability = cap
		cap.connect("prayers_changed", self, "_on_prayers_changed")
		_update()

func _on_prayers_changed(oldValue, newValue):
	_update()

func _update():
	_update_counter()
	_update_bonus()	

func _update_counter():
	if prayableCapability:
		self.counterLabel.text = String(prayableCapability.currentPrayers) + "/" + String(prayableCapability.maxPrayers)
		visible = prayableCapability.currentPrayers > 0
	
func _update_bonus():
	if prayableBonusCapability:
		var bonus = prayableBonusCapability.get_bonus()
		var bonusPercent = "+" + String((bonus - 1) * 100) + "%"
		self.bonusLabel.text = bonusPercent
