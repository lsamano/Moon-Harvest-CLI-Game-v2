class CreateAnimals < ActiveRecord::Migration[5.2]
  def change
    create_table :animals do |t|
      t.string  "species"
      t.string  "product_name"
      t.string  "action_word"
      t.integer "frequency"
      t.integer "sell_price"
      t.integer "buy_price"
    end
  end
end
