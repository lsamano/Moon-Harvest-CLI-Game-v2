class CreateLivestocks < ActiveRecord::Migration[5.2]
  def change
    create_table :livestocks do |t|
      t.integer "farmer_id"
      t.integer "animal_id"
      t.string  "name"
      t.integer "love"
      t.integer "brushed"
      t.integer "fed"
      t.integer "counter"
    end
  end
end
