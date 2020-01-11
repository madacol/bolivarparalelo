class AddCurrencyFlag < ActiveRecord::Migration[6.0]
  def change
    change_table :currencies do |t|
      t.string :flag
    end
  end
end
