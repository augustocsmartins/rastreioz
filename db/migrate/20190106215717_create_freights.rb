class CreateFreights < ActiveRecord::Migration
  def change
    create_table :rastreioz_freights do |t|
      t.integer :service
      t.integer :zipcode_start, :zipcode_end, :limit => 8
      t.float :weight_start, :weight_end
      t.integer :time_cost
      t.float :price, :handling_price, :receipt_recognition_price, default: 0.0
      t.boolean :home_delivery, :delivery_saturday, default: false
      t.timestamps
    end
    add_index :rastreioz_freights, [:service, :zipcode_start, :zipcode_end, :weight_start, :weight_end], unique: true, name: 'index_rastreioz_freights'
    add_index :rastreioz_freights, :service
    add_index :rastreioz_freights, :zipcode_start
    add_index :rastreioz_freights, :zipcode_end
    add_index :rastreioz_freights, :weight_start
    add_index :rastreioz_freights, :weight_end
  end
end
