class Floor < ApplicationRecord
  self.implicit_order_column = :created_at

  validates :name, uniqueness: true
  validates :name, length: { in: 2..20 }
  validates :level, length: { in: 1..10 }
  
  # associations
  belongs_to :tenant
  belongs_to :location
  # has_many :user_reservations
  # has_many :reservations, through: :user_reservations

  encrypts :name
  encrypts :level
end
