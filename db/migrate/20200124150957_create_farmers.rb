class CreateFarmers < ActiveRecord::Migration[6.0]
  def change
    create_table :farmers do |t|
      t.string "name"
      t.integer "day", default: 1
      t.string "dog"
      t.string "season", default: "fall"
      t.integer "money", default: 1500
      t.integer "barn_count", default: 2
    end
  end
end
