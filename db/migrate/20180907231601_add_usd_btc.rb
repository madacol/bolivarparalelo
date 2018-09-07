class AddUsdBtc < ActiveRecord::Migration[5.2]
  def change
    create_table :usd_btcs do |t|
      t.decimal   :bitcoinaverage
      t.datetime  :datetime
    end
  end
end
