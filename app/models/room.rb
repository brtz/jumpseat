class Room < ApplicationRecord
  self.implicit_order_column = :created_at

  scope :limit_floor, ->(floor) { where("floor_id = ?", floor.id) }

  validates :name, uniqueness: true
  validates :name, length: { in: 2..20 }
  
  # associations
  belongs_to :floor
  has_many :desks, dependent: :destroy
  has_many :limitations, as: :limitable

  encrypts :name
end
