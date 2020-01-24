class CreateSeedBags < ActiveRecord::Migration[6.0]
  def change
    create_table :seed_bags do |t|
      t.integer "farmer_id"
      t.integer "crop_type_id"
      t.integer "growth", default: 0
      t.integer "watered", default: 0
      t.integer "harvested", default: 0
      t.integer "planted", default: 0
      t.integer "ripe", default: 0
    end
  end
end
