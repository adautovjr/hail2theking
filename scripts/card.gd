extends MarginContainer
class_name Card

var cardInfo = null
var classInfo = null
var unitClass
var cardRealm
var eventLevel = 1


@onready var cardBase = $MarginContainer/CardBase
@onready var unitSprite = $MarginContainer/UnitSprite
@onready var eventSprite = $MarginContainer/EventSprite
@onready var modifier = $MarginContainer/Modifier
@onready var cardSellPrice = $MarginContainer/InfoContainer/SellPriceContainer/MarginContainer/CardSellPrice
@onready var statsContainer = $MarginContainer/InfoContainer/StatsContainer
@onready var hp = $MarginContainer/InfoContainer/StatsContainer/VBoxContainer/Stats1Container/HP
@onready var armor = $MarginContainer/InfoContainer/StatsContainer/VBoxContainer/Stats1Container/Armor
@onready var damage = $MarginContainer/InfoContainer/StatsContainer/VBoxContainer/Stats2Container/Damage
@onready var armorPen = $MarginContainer/InfoContainer/StatsContainer/VBoxContainer/Stats2Container/ArmorPenetration
@onready var attackSpeed = $MarginContainer/InfoContainer/StatsContainer/VBoxContainer/Stats3Container/AttackSpeed
@onready var criticalChance = $MarginContainer/InfoContainer/StatsContainer/VBoxContainer/Stats3Container/CriticalChance

const EVENT_LEVEL_WEIGHTS = {
	-3: 15,
	-2: 45,
	-1: 60,
	1: 80,
	2: 60,
	3: 20
}

func init(cardName = "tank", realm = "human"):
	var cardDB = load("res://resources/cards/CardsDatabase.gd")
	cardInfo = cardDB.DATA[cardName]
	unitClass = cardName
	cardRealm = realm

func _ready():
	statsContainer.visible = cardInfo.type == "Unit"
	cardSellPrice.text = str("$", cardInfo.sell_price)
	if cardInfo.type == "Unit":
		cardBase.frame = 1 if cardRealm == "human" else 4
		unitSprite.frame = cardInfo.sprite_frame + 63 if cardRealm == "demon" else cardInfo.sprite_frame
		unitSprite.visible = true
		eventSprite.visible = false
		modifier.frame = 143
		statsContainer.visible = true
		classInfo = load(str("res://resources/classes/class_", unitClass, "_", cardRealm, ".tres")) as ClassInfo
		return
	if cardInfo.type == "Event":
		cardBase.frame = 2 if cardRealm == "human" else 5
		eventSprite.visible = true
		eventSprite.frame = cardInfo.sprite_frame[cardRealm]
		unitSprite.frame = 143
		statsContainer.visible = false
		eventLevel = weighted_random_level_choice()
		modifier.visible = true
		match eventLevel:
			-3:
				modifier.frame = 139
			-2:
				modifier.frame = 137
			-1:
				modifier.frame = 135
			2:
				modifier.frame = 138
			3:
				modifier.frame = 140
			_:
				modifier.frame = 136


func _physics_process(_delta):
	update_unit_stats()


func update_unit_stats():
	if not classInfo:
		return

	hp.text = str(classInfo.hp + GameManager.hp_buff[cardRealm])
	armor.text = str(classInfo.armor + GameManager.armor_buff[cardRealm])
	damage.text = str(classInfo.damage + GameManager.damage_buff[cardRealm])
	armorPen.text = str(classInfo.armor_penetration + GameManager.armor_penetration_buff[cardRealm])
	attackSpeed.text = str(classInfo.attack_speed + GameManager.attack_speed_buff[cardRealm])
	criticalChance.text = str(classInfo.critical_chance, "%")


func _on_button_pressed():
	print(cardInfo)
	match cardInfo.type:
		"Unit":
			Events.emit_signal("spawnUnit", unitClass, cardRealm)
			GameManager.add_money(cardInfo.sell_price)
		"Event":
			GameManager.handle_card_buff(cardInfo, eventLevel, cardRealm)
			GameManager.add_money(cardInfo.sell_price)
		_:
			print(cardInfo.type + " card not Implemented yet")
	queue_free()


func weighted_random_level_choice():
	var levels = EVENT_LEVEL_WEIGHTS.keys()
	var weights = EVENT_LEVEL_WEIGHTS.values()
	var weightsCopy: Array = weights.duplicate(true)
	var totalProbability: int = 0

	for i in weights.size():
		totalProbability += int(weightsCopy[i])
		continue

	var chosenOptionInt: int = GameManager.rand_int(0, totalProbability)

	var growingProbability: int = 0
	for a in weightsCopy.size():
		growingProbability += int(weightsCopy[a])
		weightsCopy[a] = growingProbability

		if weightsCopy[a] > chosenOptionInt:
			return levels[a]

		if chosenOptionInt <= weightsCopy[weightsCopy.size()-1]:
			return levels[weightsCopy.size()-1]
