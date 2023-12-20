# frozen_string_literal: true

class CreateTenants < ActiveRecord::Migration[7.1]
  def change
    create_table :tenants, id: :uuid do |t|
      t.string :name, null: false

      t.integer :users_count
      t.integer :locations_count

      t.timestamps
    end
  end
end
