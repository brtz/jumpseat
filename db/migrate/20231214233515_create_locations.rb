class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations, id: :uuid do |t|
      t.string :street
      t.string :house_number
      t.string :zip_code
      t.string :city
      t.string :state
      t.string :country
      t.string :name
      t.references :tenant, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_index :locations, :name, unique: true
  end
end
