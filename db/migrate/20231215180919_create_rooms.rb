class CreateRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :rooms, id: :uuid do |t|
      t.string :name
      t.references :floor, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
