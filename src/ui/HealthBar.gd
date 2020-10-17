extends ProgressBar

class_name HealthBar

func _ready():
	_on_health_changed(get_parent().maxHealth, get_parent().health)
	get_parent().connect("health_changed", self, "_on_health_changed")

func _on_health_changed(oldHealth, newHealth):
	value = newHealth * 100.0 / get_parent().maxHealth
