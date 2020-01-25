class CreateLivestocks < ActiveRecord::Migration[5.2]
  def change
    create_table :livestocks do |t|
      t.integer "farmer_id"
      t.integer "animal_id"
      t.string  "name"
      t.integer "love", default: 1
      t.integer "brushed", default: 0
      t.integer "fed", default: 0
      t.integer "day_counter_for_product", default: 1
    end
  end
end
