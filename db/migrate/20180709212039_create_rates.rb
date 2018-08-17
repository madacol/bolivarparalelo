class CreateRates < ActiveRecord::Migration[5.2]
  def self.up
    create_table :rates do |t|
      t.decimal   :usd_btc_avg
      t.decimal   :vef_btc_buy
      t.decimal   :vef_btc_sell
      t.decimal   :vef_btc_avg_1h
      t.datetime  :date
    end
  end
  def self.down
    drop_table :rates
  end
end
