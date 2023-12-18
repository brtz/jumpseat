# frozen_string_literal: true

class CreateLimitations < ActiveRecord::Migration[7.1]
  def change
    create_table :limitations, id: :uuid do |t|
      t.references :limitable, polymorphic: true, type: :uuid

      t.string :name
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false

      t.timestamps
    end
    add_index :limitations, :name, unique: true
  end
end
