class CreateFarmers < ActiveRecord::Migration[5.2]
  def change
    create_table :farmers do |t|
      t.string "name"
      t.integer "day", default: 1
      t.string "dog"
      t.string "season", default: "fall"
      t.integer "money", default: 2000
    end
  end
end
