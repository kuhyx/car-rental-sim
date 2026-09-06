extends Node
## Autoloaded singleton: wallet, current car, damage, and the car catalog.
## Every mutation is persisted immediately, so there is no explicit "save".

signal money_changed(amount: int)
signal damage_changed(damage: float)
signal car_changed(car_id: String)

## How much of the top speed survives at 100% damage.
const WRECKED_SPEED_FACTOR := 0.4
const REPAIR_COST_PER_POINT := 2.0

class CarModel:
	var id: String
	var display_name: String
	var price: int
	var max_health: float
	var capacity: int
	var size: Vector2
	var body: Color
	var trim: Color

	func _init(p_id: String, p_name: String, p_price: int, p_max_health: float,
			p_capacity: int, p_size: Vector2, p_body: Color, p_trim: Color) -> void:
		id = p_id
		display_name = p_name
		price = p_price
		max_health = p_max_health
		capacity = p_capacity
		size = p_size
		body = p_body
		trim = p_trim

var money: int = 500
var damage: float = 0.0
var current_car: CarModel
var catalog: Array[CarModel] = []

func _ready() -> void:
	catalog = [
		CarModel.new("hatchback", "Rusty Hatchback", 0, 60.0, 1,
			Vector2(26, 40), Palette.PEACH, Palette.INK),
		CarModel.new("sedan", "Sturdy Sedan", 400, 100.0, 2,
			Vector2(28, 50), Palette.CORAL, Palette.INK),
		CarModel.new("suv", "Armored SUV", 900, 160.0, 3,
			Vector2(32, 56), Palette.INK, Palette.CREAM),
	]
	current_car = catalog[0]
	_restore(SaveStore.read())

func find_car(car_id: String) -> CarModel:
	for c in catalog:
		if c.id == car_id:
			return c
	return null

func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)
	_persist()

func apply_damage(amount: float) -> void:
	damage = clamp(damage + amount, 0.0, current_car.max_health)
	damage_changed.emit(damage)
	_persist()

func damage_percent() -> float:
	return 100.0 * damage / current_car.max_health

## 1.0 when pristine, WRECKED_SPEED_FACTOR when the car is at max damage.
func speed_factor() -> float:
	return lerp(1.0, WRECKED_SPEED_FACTOR, damage / current_car.max_health)

func repair_cost() -> int:
	return int(ceil(damage * REPAIR_COST_PER_POINT))

func repair() -> bool:
	var cost := repair_cost()
	if cost == 0 or money < cost:
		return false
	money -= cost
	damage = 0.0
	money_changed.emit(money)
	damage_changed.emit(damage)
	_persist()
	return true

## Swaps the active car if it's a different model the player can afford.
func buy_car(car_id: String) -> bool:
	var target := find_car(car_id)
	if target == null or target.id == current_car.id or money < target.price:
		return false
	money -= target.price
	current_car = target
	damage = 0.0
	money_changed.emit(money)
	damage_changed.emit(damage)
	car_changed.emit(current_car.id)
	_persist()
	return true

func _persist() -> void:
	SaveStore.write({"money": money, "damage": damage, "car": current_car.id})

func _restore(data: Dictionary) -> void:
	if data.is_empty():
		return
	var saved_car := find_car(str(data.get("car", "")))
	if saved_car != null:
		current_car = saved_car
	money = int(data.get("money", money))
	damage = clamp(float(data.get("damage", 0.0)), 0.0, current_car.max_health)
