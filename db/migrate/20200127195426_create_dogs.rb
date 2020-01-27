class CreateDogs < ActiveRecord::Migration[5.2]
  def change
    create_table :dogs do |t|
      t.string "name"
      t.integer "farmer_id"
      t.integer "love", default: 1
      t.integer "petted", default: 0
    end
  end
end
