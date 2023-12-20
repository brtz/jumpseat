# frozen_string_literal: true

class CreateDesks < ActiveRecord::Migration[7.1]
  def change
    create_table :desks, id: :uuid do |t|
      t.string :name
      t.references :room, null: false, foreign_key: true, type: :uuid
      t.integer :pos_x
      t.integer :pos_y
      t.integer :width
      t.integer :height
      t.enum :required_position, default: "employee", null: false, enum_type: :positions

      t.timestamps

      t.integer :reservations_count, default: 0
    end
    add_index :desks, :name, unique: true
  end
end
