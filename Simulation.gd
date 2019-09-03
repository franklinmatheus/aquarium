extends Node2D

var Fish = preload("res://scenes/fish.tscn")
var Food = preload("res://scenes/food.tscn")

export var speedRangeMin = 30
export var speedRangeMax = 100

export var energyRangeMin = 1
export var energyRangeMax = 10

export var radarSizeRangeMin = 50 
export var radarSizeRangeMax = 100

export var initialPopulation = 10
export var dailyFood = 10
export var mutationRate = 0.2

var foods = []
var fishes = []

func _ready():
	randomize()
	create_fishes()
	create_foods()
	pass

func _process(delta):
	food_step()
	
	if !has_any_food():
		clear_dead_fishes()
		reset_fishes()
		reproduce()
		create_foods()

func reproduce():
	for fish in fishes:
		if fish.extras.foodEatenToday > 1:
			create_fish(fish)

func food_step():
	for fish in fishes:
		var toRemove = []
		var index = -1
		for food in foods:
			index += 1
			if food.eaten:
				toRemove.push_front(index)
				continue
				
			var distance = (fish.position - food.position).length()
			if distance <= fish.get_food_radar_size():
				fish.look_at_food(food)
			else:
				fish.look_straight()
		
		for food_index in toRemove:
			foods[food_index].queue_free()
			foods.remove(food_index)

func has_any_food():
	return foods.size() > 0
	
func clear_dead_fishes():
	var toRemove = []
	var index = -1
	
	for fish in fishes:
		index += 1
		if fish.currentState == "morto":
			toRemove.push_front(index)
	
	for i in toRemove:
		fishes[i].queue_free()
		fishes.remove(i)
	

func reset_fishes():
	for fish in fishes:
		fish.position = fish.extras.initialPosition
		fish.direction = fish.extras.initialDirection

func create_fishes():
	for i in range(0, initialPopulation):
		create_fish(null)

func create_foods():
	for i in range(0, dailyFood):
		create_food()

func rand_int_range(min_value, max_value):
	return int((randi() % int(max_value - min_value + 1)) + min_value)

func create_fish(parent):
	var fish = Fish.instance()
	
	if !parent:
		fish.normalSpeed = rand_int_range(speedRangeMin, speedRangeMax)
		fish.maxEnergy = rand_int_range(energyRangeMin, energyRangeMax)
		fish.foodRadarSize = rand_int_range(radarSizeRangeMin, radarSizeRangeMax)
	else:
		fish.normalSpeed = rand_int_range(
				parent.normalSpeed * (1.0 - mutationRate), 
				parent.normalSpeed * (1.0 + mutationRate)
			)
		fish.maxEnergy = rand_int_range(
				parent.maxEnergy * (1.0 - mutationRate), 
				parent.maxEnergy * (1.0 + mutationRate)
			)
		fish.foodRadarSize = rand_int_range(
				parent.foodRadarSize * (1.0 - mutationRate), 
				parent.foodRadarSize * (1.0 + mutationRate)
			)
	
	fish.energy = rand_int_range(0, fish.maxEnergy)
	
	if randi() % 2:
		fish.position.x = get_viewport().size.x - fish.margin
		fish.direction = -1
	else:
		fish.position.x = fish.margin
	
	fish.position.y = rand_range(fish.margin, get_viewport().size.y - fish.margin)
	
	fish.extras.initialPosition = Vector2(fish.position.x, fish.position.y)
	fish.extras.initialDirection = fish.direction
	fish.extras.foodEatenToday = 0
	
	fish.connect("food_eaten", self, "on_food_eaten")
	
	add_child(fish)
	fishes.append(fish)

func on_food_eaten(fish):
	fish.extras.foodEatenToday += 1

func create_food():
	var food = Food.instance()
	food.position.x = rand_range(64, get_viewport().size.x - 64)
	food.position.y = rand_range(10, get_viewport().size.y - 10)
	
	add_child(food)
	foods.append(food)