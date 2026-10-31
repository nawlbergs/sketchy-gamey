class_name Gear
extends RefCounted
## Wearable gear data. These two items are placeholders so the hero doll has something to show.
##
## slot is the GameEnums.GearSlot the item goes in. art is the image the hero doll draws;
## until that file exists, the doll draws a placeholder shape labeled with the item's name.

const ALL: Dictionary = {
	GameEnums.GearId.LEATHER_CAP: {
		"name": "Leather Cap",
		"slot": GameEnums.GearSlot.HEAD,
		"art": "res://assets/art/characters/gear/leather_cap.png",
	},
	GameEnums.GearId.LEATHER_ARMOR: {
		"name": "Leather Armor",
		"slot": GameEnums.GearSlot.BODY,
		"art": "res://assets/art/characters/gear/leather_armor.png",
	},
}
