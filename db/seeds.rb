# Destroy Previous
Product.destroy_all
Livestock.destroy_all
SeedBag.destroy_all
CropType.destroy_all
Animal.destroy_all
Farmer.destroy_all

######################################################
## Create Animals
######################################################
cow = Animal.create(
  species: "cow",
  product_name: "milk",
  sell_price: 400,
  frequency: 1
  )
sheep = Animal.create(
  species: "sheep",
  product_name: "wool",
  sell_price: 1000,
  frequency: 3
  )

######################################################
## Crop Creation
######################################################
## Fall Crops
CropType.create(
  crop_name: "carrot",
  days_to_grow: 6,
  buy_price: 390,
  season: "fall",
  sell_price: 1710
)
CropType.create(
  crop_name: "sweet potato",
  days_to_grow: 6,
  buy_price: 240,
  season: "fall",
  sell_price: 990
)
CropType.create(
  crop_name: "spinach",
  days_to_grow: 5,
  buy_price: 440,
  season: "fall",
  sell_price: 1890
)
CropType.create(
  crop_name: "eggplant",
  days_to_grow: 11,
  buy_price: 480,
  season: "fall",
  sell_price: 4140
)
CropType.create(
  crop_name: "bell pepper",
  days_to_grow: 11,
  buy_price: 510,
  season: "fall",
  sell_price: 2250
)

# ## Summer Crops
# CropType.create(
#   crop_name: "pumpkin",
#   days_to_grow: 4,
#   buy_price: 180,
#   season: "summer",
#   sell_price: 1620
# )
# CropType.create(
#   crop_name: "watermelon",
#   days_to_grow: 7,
#   buy_price: 360,
#   season: "summer",
#   sell_price: 3060
# )
# CropType.create(
#   crop_name: "onion",
#   days_to_grow: 6,
#   buy_price: 270,
#   season: "summer",
#   sell_price: 1260
# )
# CropType.create(
#   crop_name: "corn",
#   days_to_grow: 14,
#   buy_price: 140,
#   season: "summer",
#   sell_price: 3960
# )
# CropType.create(
#   crop_name: "tomato",
#   days_to_grow: 12,
#   buy_price: 110,
#   season: "summer",
#   sell_price: 3240
# )

# ## Spring Crops
# CropType.create(
#   crop_name: "cabbage",
#   days_to_grow: 13,
#   buy_price: 810,
#   season: "spring",
#   sell_price: 3690
# )
# CropType.create(
#   crop_name: "potato",
#   days_to_grow: 8,
#   buy_price: 450,
#   season: "spring",
#   sell_price: 1890
# )
# CropType.create(
#   crop_name: "strawberry",
#   days_to_grow: 15,
#   buy_price: 1350,
#   season: "spring",
#   sell_price: 4320
# )
# CropType.create(
#   crop_name: "turnip",
#   days_to_grow: 5,
#   buy_price: 180,
#   season: "spring",
#   sell_price: 990
# )
# CropType.create(
#   crop_name: "cucumber",
#   days_to_grow: 9,
#   buy_price: 720,
#   season: "spring",
#   sell_price: 2160
# )
#
# ## Winter Crops
# CropType.create(
#   crop_name: "broccoli",
#   days_to_grow: 8,
#   buy_price: 540,
#   season: "spring",
#   sell_price: 1620
# )
# CropType.create(
#   crop_name: "daikon",
#   days_to_grow: 4,
#   buy_price: 180,
#   season: "spring",
#   sell_price: 810
# )


# ######################################################
# ## Gift Creation
# ######################################################
# susans = Gift.create(
#   name: "Black-Eyed Susan",
#   flavor_text: "A painful-sounding name for a quaint flower.",
#   buy_price: 1100,
#   sell_price: 275
# )
# teddy = Gift.create(
#   name: "Teddy Bear",
#   flavor_text: "Stares into your soul. But you like it.",
#   buy_price: 2000,
#   sell_price: 500
# )
# tiramisu = Gift.create(
#   name: "Tiramisu",
#   flavor_text: "As fun to eat as it is to say!",
#   buy_price: 500,
#   sell_price: 125
# )
#
# ######################################################
# ## Character Creation
# ######################################################
# # Create Characters
# Character.create(
#   name: "Clarabelle",
#   gift_to_give_id: susans.id,
#   fave_gift_id: susans.id
# )
