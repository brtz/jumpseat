# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2023_12_16_032418) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "positions", ["trainee", "apprentice", "employee", "lead", "management"]

  create_table "desks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "room_id", null: false
    t.integer "pos_x", default: 1
    t.integer "pos_y", default: 1
    t.enum "required_position", default: "employee", null: false, enum_type: "positions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reservations_count", default: 0
    t.index ["name"], name: "index_desks_on_name", unique: true
    t.index ["room_id"], name: "index_desks_on_room_id"
  end

  create_table "floors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "level"
    t.string "name"
    t.uuid "location_id", null: false
    t.integer "rooms_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_floors_on_location_id"
    t.index ["name"], name: "index_floors_on_name", unique: true
  end

  create_table "limitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "limitable_type"
    t.uuid "limitable_id"
    t.string "name"
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["limitable_type", "limitable_id"], name: "index_limitations_on_limitable"
    t.index ["name"], name: "index_limitations_on_name", unique: true
  end

  create_table "locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "street"
    t.string "house_number"
    t.string "zip_code"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "name"
    t.uuid "tenant_id", null: false
    t.integer "floors_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_locations_on_name", unique: true
    t.index ["tenant_id"], name: "index_locations_on_tenant_id"
  end

  create_table "reservations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.uuid "desk_id", null: false
    t.uuid "user_id", null: false
    t.boolean "shared", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["desk_id"], name: "index_reservations_on_desk_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "rooms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "floor_id", null: false
    t.integer "desks_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["floor_id"], name: "index_rooms_on_floor_id"
  end

  create_table "tenants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.integer "users_count", default: 0
    t.integer "locations_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.enum "current_position", default: "employee", null: false, enum_type: "positions"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "middle_name", default: "", null: false
    t.string "last_name", null: false
    t.boolean "admin", default: false
    t.integer "quota_max_reservations", default: 45
    t.integer "reservations_count", default: 0
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.uuid "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "desks", "rooms"
  add_foreign_key "floors", "locations"
  add_foreign_key "locations", "tenants"
  add_foreign_key "reservations", "desks"
  add_foreign_key "reservations", "users"
  add_foreign_key "rooms", "floors"
end
