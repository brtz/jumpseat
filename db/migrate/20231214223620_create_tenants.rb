# frozen_string_literal: true

class CreateTenants < ActiveRecord::Migration[7.1]
  def change
    create_table :tenants, id: :uuid do |t|
      t.string :name, null: false

      t.integer :users_count, default: 0
      t.integer :locations_count, default: 0

      t.timestamps
    end
  end
end
