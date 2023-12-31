# frozen_string_literal: true

class CreateRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :rooms, id: :uuid do |t|
      t.string :name
      t.references :floor, null: false, foreign_key: true, type: :uuid

      t.integer :desks_count, default: 0

      t.timestamps
    end
  end
end
