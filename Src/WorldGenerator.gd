extends Node

@onready var tm: Object = $TileMap
@export var size: Vector2 = Vector2(100,100)

@export var n: FastNoiseLite = FastNoiseLite.new()

var temperature = {}
var moisture = {}
var altitude = {}

var Tiles = {
	DEEP_WATER = Vector2i(0, 0),
	LAKE = Vector2i(0, 1),
	JUNGLE = Vector2i(0, 2),
	PLAINS = Vector2i(0, 3),
	DESERT = Vector2i(0, 4),
	TUNDRA = Vector2i(0, 5),
	TAIGA = Vector2i(0,6),
	SNOW = Vector2i(0, 7),
	LAVA = Vector2i(0,8)
	}

func _ready():
#	tm.set_cell(0, Vector2i(1,1), 0, Vector2i(0,0), 0)
	temperature = generate_world(5, 0.01)
	moisture = generate_world(5, 0.01)
	altitude = generate_world(5, 0.01)
	set_tile(size.x, size.y)
	
func generate_world(oct, gain):
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH #TYPE_SIMPLEX, TYPE_PERLIN, TYPE_SIMPLEX_SMOOTH, TYPE_CELLULAR,
	n.seed = randi()#123456 #test
	n.frequency = gain
	n.fractal_octaves = oct
	
	var gridName = {}
	for x in size.x:
		for y in size.y:
			var rand = 2*(abs(n.get_noise_2d(x,y)))
			gridName[Vector2(x,y)] = rand
	return gridName

func set_tile(width, height):
	for x in width:
		for y in height:
			var pos = Vector2(x,y)
			var alt = altitude[pos]
			var temp = temperature[pos]
			var moist = moisture[pos]
			
			#Ocean
			if between(alt, 0, 0.1):
				tm.set_cell(0, pos, 0, Tiles.DEEP_WATER, 0)
			#Beach
			elif between(alt, 0.1, 0.3):
				if moist > 0.8:
					tm.set_cell(0, pos, 0, Tiles.DESERT)
				else:
					tm.set_cell(0, pos, 0, Tiles.LAKE)
			#OtherBiomes
			elif between(alt, 0.3, 0.8):
				if between(moist, 0, 0.8):
					if between(temp, 0.2, 0.4):
						tm.set_cell(0, pos, 0, Tiles.PLAINS)
					if between(temp, 0.1, 0.2):
						tm.set_cell(0, pos, 0, Tiles.TAIGA)
					elif temp < 0.1:
						tm.set_cell(0, pos, 0, Tiles.SNOW)
				if between(moist, 0.4, 0.8) and temp > 0.4:
					tm.set_cell(0, pos, 0, Tiles.PLAINS)
				if moist > 0.8:
					tm.set_cell(0, pos, 0, Tiles.LAKE)
				elif  temp > 0.5 and moist < 0.4:
					tm.set_cell(0, pos, 0, Tiles.DESERT)
			else:
				tm.set_cell(0, pos, 0,Tiles.PLAINS)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()


func between(val, start, end):
	if start <= val and val < end:
		return true
