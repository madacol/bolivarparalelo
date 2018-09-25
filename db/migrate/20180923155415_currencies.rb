class Currencies < ActiveRecord::Migration[5.2]
  def change
    create_table :currencies do |t|
      t.string :code
      t.timestamps
    end
  end
end
