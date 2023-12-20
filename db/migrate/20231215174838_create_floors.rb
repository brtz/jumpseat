# frozen_string_literal: true

class CreateFloors < ActiveRecord::Migration[7.1]
  def change
    create_table :floors, id: :uuid do |t|
      t.string :level
      t.string :name
      t.references :location, null: false, foreign_key: true, type: :uuid

      t.integer :rooms_count, default: 0

      t.timestamps
    end
    add_index :floors, :name, unique: true
  end
end
