class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string  "livestock_id"
      t.integer "farmer_id"
    end
  end
end
