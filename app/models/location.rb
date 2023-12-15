class Location < ApplicationRecord
  self.implicit_order_column = :created_at

  validates :name, uniqueness: true
  validates :name, length: { in: 2..20 }
  validates :street, length: { in: 2..30 }
  validates :house_number, length: { in: 0..10 }
  validates :zip_code, length: { in: 2..10 }
  validates :city, length: { in: 2..30 }
  validates :state, length: { in: 2..20 }
  validates :country, length: { in: 2..20 }

  # associations
  belongs_to :tenant
  # has_many :user_reservations
  # has_many :reservations, through: :user_reservations

  encrypts :name
  encrypts :street
  encrypts :house_number
  encrypts :zip_code
  encrypts :city
  encrypts :state
  encrypts :country
end
