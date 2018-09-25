class UnifyAgainRates < ActiveRecord::Migration[5.2]
  def change
    create_table :lobit_prices do |t|
      t.decimal     :sell
      t.decimal     :buy
      t.decimal     :avg_1h
      t.belongs_to  :currency
      t.timestamps
    end
  end
end
