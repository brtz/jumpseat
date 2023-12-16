class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations, id: :uuid do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.references :desk, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
