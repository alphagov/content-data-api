class CreateDimensionsMonths < ActiveRecord::Migration[5.2]
  def change
    create_table :dimensions_months, id: false do |t|
      t.string :id, null: false
      t.string :month_name, null: false
      t.string :month_name_abbreviated, null: false
      t.integer :month_number, null: false
      t.integer :quarter, null: false
      t.integer :year, null: false

      t.timestamps null: false
      t.index :id, unique: true
    end
  end
end
