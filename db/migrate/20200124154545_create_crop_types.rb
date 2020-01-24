class CreateCropTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :crop_types do |t|
      t.string  "crop_name"
      t.integer "days_to_grow"
      t.integer "buy_price"
      t.string  "season"
      t.integer "sell_price"
    end
  end
end
