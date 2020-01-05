class AddCurrencyName < ActiveRecord::Migration[6.0]
  def change
    change_table :currencies do |t|
      t.string :symbol
      t.string :name
      t.string :namePlural
    end
  end
end
