# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

admin_tenant = Tenant.create(name: "Admin Tenant") if Tenant.find_by("name='Admin Tenant'").nil?
User.create(email: "admin@jumpseat", password: "initial", first_name: "Jumpseat", last_name: "Admin", current_position: "management", admin: true, tenant: admin_tenant) if User.find_by("email='admin@jumpseat'").nil?

if ENV["RAILS_ENV"] == "development"
  acme = Tenant.create(name: "ACME")
  User.create(email: "user@jumpseat", password: "initial", first_name: "Jumpseat", last_name: "User", current_position: "trainee", admin: false, tenant: acme)
  home = Location.create(name: "home", street: "Musterstrasse", house_number: "1", zip_code: "20095", city: "Hamburg", state: "Hamburg", country: "Germany", tenant: acme)
  thirteenth = Floor.create(name: "13th floor", level: "13", location: home)
  darkroom = Room.create(name: "Darkroom", floor: thirteenth)
  lightroom = Room.create(name: "Lightroom", floor: thirteenth)
  desk1 = Desk.create(name: "Desk 1", room: darkroom, pos_x: 0, pos_y: 0, width: 40, height: 60, required_position: "employee")
  desk2 = Desk.create(name: "Desk 2", room: darkroom, pos_x: 0, pos_y: 70, width: 40, height: 60, required_position: "employee")
  desk3 = Desk.create(name: "Desk 3", room: lightroom, pos_x: 0, pos_y: 70, width: 40, height: 60, required_position: "employee")
  christmas = Limitation.create(name: "ACME Christmas", start_date: "2023-12-24T000000", end_date: "2023-12-27T000000")
  acme.limitation_ids = [christmas.id]
  acme.save
end
