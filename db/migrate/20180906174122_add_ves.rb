class AddVes < ActiveRecord::Migration[5.2]
  def change
    create_table :ves_btcs do |t|
      t.decimal   :buy
      t.decimal   :sell
      t.decimal   :avg_1h
      t.datetime  :datetime
    end
  end
end
