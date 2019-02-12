class CreateFreights < ActiveRecord::Migration[5.2]
  def change
    create_table :freights, id: :uuid do |t|
      t.string :zipcode_start, :zipcode_end


      ,"WeightStart","WeightEnd","AbsoluteMoneyCost","PricePercent","PriceByExtraWeight","MaxVolume","TimeCost","Country","MinimumValueInsurance"


      t.timestamps
    end
    add_index :freights, :hashed_url

  end
end
