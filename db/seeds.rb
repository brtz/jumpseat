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

User.create(email: "admin@jumpseat", password: "initial", first_name: "Jumpseat", last_name: "Admin", current_position: "management", admin: true) if User.find_by("email='admin@jumpseat'").nil?

if ENV["RAILS_ENV"] == "development"

end
