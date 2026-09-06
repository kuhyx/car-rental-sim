extends CanvasLayer
class_name Hud
## Status readout plus the garage panel. Emits intents; `main.gd` decides.

signal buy_requested(car_id: String)
signal repair_requested

var money_label: Label
var damage_label: Label
var passengers_label: Label
var status_label: Label
var garage_panel: PanelContainer
var garage_title: Label
var repair_button: Button
var buy_buttons: Dictionary = {}

static func create(panel_center: Vector2) -> Hud:
	var hud := Hud.new()
	hud._build_readout()
	hud._build_garage_panel(panel_center)
	return hud

func set_status(text: String) -> void:
	status_label.text = text

func set_money(amount: int) -> void:
	money_label.text = "Money: $%d" % amount
	_refresh_garage()

func set_damage() -> void:
	damage_label.text = "Damage: %d%%" % int(GameState.damage_percent())
	_refresh_garage()

func set_passengers(count: int) -> void:
	passengers_label.text = "Passengers: %d/%d" % [count, GameState.current_car.capacity]

func toggle_garage() -> void:
	garage_panel.visible = not garage_panel.visible
	if garage_panel.visible:
		_refresh_garage()

func hide_garage() -> void:
	garage_panel.visible = false

func _refresh_garage() -> void:
	var current := GameState.current_car
	garage_title.text = "Garage -- current car: %s" % current.display_name
	for car_id: String in buy_buttons:
		var model := GameState.find_car(car_id)
		var button: Button = buy_buttons[car_id]
		var owned := model.id == current.id
		button.disabled = owned or GameState.money < model.price
		button.text = "%s -- %s  (durability %d, seats %d)" % [
			model.display_name,
			"owned" if owned else "$%d" % model.price,
			int(model.max_health), model.capacity]
	var cost := GameState.repair_cost()
	repair_button.disabled = cost == 0 or GameState.money < cost
	repair_button.text = "Repair -- $%d" % cost if cost > 0 else "Repair -- nothing to fix"

func _build_readout() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	add_child(margin)
	var panel := _panel()
	margin.add_child(panel)
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)
	money_label = _label(vbox)
	damage_label = _label(vbox)
	passengers_label = _label(vbox)
	status_label = _label(vbox)

func _build_garage_panel(center: Vector2) -> void:
	garage_panel = _panel()
	garage_panel.visible = false
	garage_panel.position = center - Vector2(180.0, 90.0)
	add_child(garage_panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	garage_panel.add_child(vbox)
	garage_title = _label(vbox)
	for model in GameState.catalog:
		var button := _button(vbox)
		button.pressed.connect(func() -> void:
			button.release_focus()
			buy_requested.emit(model.id))
		buy_buttons[model.id] = button
	repair_button = _button(vbox)
	repair_button.pressed.connect(func() -> void:
		repair_button.release_focus()
		repair_requested.emit())

func _panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Palette.INK
	style.border_color = Palette.CORAL
	style.set_border_width_all(2)
	style.set_content_margin_all(10.0)
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _label(parent: Control) -> Label:
	var label := Label.new()
	label.add_theme_color_override("font_color", Palette.CREAM)
	parent.add_child(label)
	return label

## Buttons get every state restyled so the default grey theme never shows.
func _button(parent: Control) -> Button:
	var button := Button.new()
	button.add_theme_color_override("font_color", Palette.CREAM)
	button.add_theme_color_override("font_hover_color", Palette.INK)
	button.add_theme_color_override("font_pressed_color", Palette.INK)
	button.add_theme_color_override("font_focus_color", Palette.CREAM)
	button.add_theme_color_override("font_disabled_color", Palette.PEACH)
	button.add_theme_stylebox_override("normal", _button_style(Palette.INK))
	button.add_theme_stylebox_override("hover", _button_style(Palette.CORAL))
	button.add_theme_stylebox_override("pressed", _button_style(Palette.PEACH))
	button.add_theme_stylebox_override("disabled", _button_style(Palette.INK))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	parent.add_child(button)
	return button

func _button_style(bg: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = Palette.CORAL
	style.set_border_width_all(1)
	style.set_content_margin_all(6.0)
	return style
