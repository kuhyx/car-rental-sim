extends Node
## Autoloaded singleton: wallet, current car, and the car catalog.

signal money_changed(amount: int)
signal damage_changed(damage: float)
signal car_changed(car_id: String)

class CarModel:
	var id: String
	var display_name: String
	var price: int
	var max_health: float
	var color: Color

	func _init(p_id: String, p_name: String, p_price: int, p_max_health: float, p_color: Color) -> void:
		id = p_id
		display_name = p_name
		price = p_price
		max_health = p_max_health
		color = p_color

var money: int = 500
var damage: float = 0.0
var current_car: CarModel
var catalog: Array[CarModel] = []

func _ready() -> void:
	catalog = [
		CarModel.new("hatchback", "Rusty Hatchback", 0, 60.0, Color8(150, 150, 150)),
		CarModel.new("sedan", "Sturdy Sedan", 400, 100.0, Color8(60, 120, 200)),
		CarModel.new("suv", "Armored SUV", 900, 160.0, Color8(90, 160, 90)),
	]
	current_car = catalog[0]

func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

func apply_damage(amount: float) -> void:
	damage = clamp(damage + amount, 0.0, current_car.max_health)
	damage_changed.emit(damage)

func damage_percent() -> float:
	return 100.0 * damage / current_car.max_health

## Swaps the active car if it's a different model the player can afford.
func buy_car(car_id: String) -> bool:
	var target: CarModel = null
	for c in catalog:
		if c.id == car_id:
			target = c
			break
	if target == null or target.id == current_car.id or money < target.price:
		return false
	money -= target.price
	current_car = target
	damage = 0.0
	money_changed.emit(money)
	damage_changed.emit(damage)
	car_changed.emit(current_car.id)
	return true
