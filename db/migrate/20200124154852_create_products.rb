class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string  "livestock_id"
      t.integer "farmer_id"
    end
  end
end
