## PRODUCTION LOG

### Jan 04, 2019
- Finished adding cow and sheep, ability to get their products, and sell them.

### Jan 03, 2019
- Created branch "adding_animals" in order to add a barn and three new models.

### Jan 01, 2019
- Added terminal-table gem and cleaned up table UIs.
- Added some flavor texts to the Home.
- Added ability to delete Farmer files from the opening screen.
- Made it impossible to buy seed bags if the player doesn't have enough money.
- Incorporated a storyline.
  - Opening sequence established upon character creation.
  - Game is finished when you complete your goal.
- Refactored some code.

### Dec 30, 2018
- Planned more.
- Updated crop_types table to include established sell prices.
- Made it so that the player loses money when buying new seed bags.
- Made it so that the player can sell all of their harvested crops at once.
- Placed Inventory back on its own screen.

### Dec 29, 2018
- Made many edits to all tables:
  - Renamed SeedBag to CropType
  - Renamed Crop to SeedBag (the join table)
  - In the new :seed_bags table (join table)
    - Added :ripe (integer) column
    - Renamed :days_planted to :growth
    - Renamed :seed_bag_id to :crop_type_id
  - In the new :crop_types table
    - Added :sell_price (integer) column
    - Renamed :price to :buy_price
    - Renamed :seed_name to :crop_name
  - In :farmers
    - Added :day (integer) column
    - Added :dog (string) column
    - Added :season (string) column
    - Added :money (integer) column

- Added Sleep function, which
  - increments farmer.day
  - increments :growth on all watered crops
  - Makes all watered crops dry again
  - Checks all planted crops if they qualify as "ripe"
    and flips on the boolean for it
- Added Harvest function, which
  - makes harvested = true and planted = false
- Added Destroy function, which
  - Allows you to destroy planted crops
- Added Rename function in Home, which
  - Allows you to rename your farmer
  - Allows you to rename your dog

- Reworked Inventory to separate seed bags from harvested crops.
- Shows brief version of the inventory on the Plant screen.
- Added default season of "fall" and 5000G upon character creation.
- Added :money and :day to the top of the main game menu UI.
- Added :growth as a percentage on the Field screen.
- Reworked all select prompts to be able to show duplicate crop types.
- Created "notice" helper method showing red text for ease of reading.
- Refactored some things.

- Still need to:
  - Establish sell prices of the crop types in the database.
  - Incorporate money functionality.
  - Incorporate story plot.
  - Add cleaner UI, graphics, and sounds.

### Dec 28, 2018
- Planned more.

### Dec 27, 2018
- Added "seasons" column to seed_bags table.
- Added Fall crops to database. That is:
  - Carrot, sweet potato, spinach, eggplant, bell pepper
- Added counting method to count duplicate seed bags and print them neatly to
  the screen on the inventory page and planting screen (in Field).
- User can buy single bags from the Market from a list of seed bags.
- Renamed Status to Inventory, added functionality to Inventory.
  - Inventory shows unplanted crops only.
- Field shows list of planted crops only.
  - Also shows watered status with colored text for ease of reading.
- User can water crops in the field that are unwatered.

- Still need to:
  - Add remaining actions to the Field (plant, harvest, destroy).

### Dec 26, 2018
- Planned out crops database, setting, and plot.

### Dec 23, 2018
- Created Start Screen Menu (New Game, Load Game, Exit).
  - User can create a farmer or select from existing farmers.
- Created Main Game Menu (Status, Field, Market, Home, Exit).
  - Status: Check inventory and Farmer info.
  - Field: Check planted crops.
  - Market: Buy new seeds or sell grown crops.
  - Home: Sleep to advance to the next day.
  - Exit: Quit the game.
- User can create crop instances (buy from the market).
- Seed bag ownership is considered a part of the Crop instance (days = 0)

- Still need to:
  - Add functionality to all choices of the Main Game Menu except Exit.
  - Create SeedBag database with proper seeds in season.
  - Create Day counter of some sort.

### Dec 22, 2018
- Planned out app
  - "Lite" version of a farming simulator.
  - Create a farmer and grow and sell crops.
- Fixed environment and file connectivity
- Added models: Farmer, Crop, SeedBag, CommandLineInterface
- Created tables: farmers, crops, seed_bags
- Connected the above tables in a "has-many-through" relationship
  - Crop is the join table
  - CommandLineInterface is for UI actions (future TTYPrompt)

- Still need to:
  - Fill database with dummy data
  - Establish menu using TTYPrompt
    - Loop menu until the user exits the game
  - Allow user to perform CRUD actions
    - Create a farmer, plant crops (create crops)
    - Read farmer name, current crops, past crops
    - Update name, water plants
    - Destroy crops, sell crops
  - I may have to account for seed bag ownership and change relationships.
