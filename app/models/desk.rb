class Desk < ApplicationRecord
  self.implicit_order_column = :created_at

  validates :name, uniqueness: true
  validates :name, length: { in: 2..20 }
  validates :required_position, inclusion: { in: %w(trainee apprentice employee lead management), message: "%{value} is not a valid position" }
  
  # associations
  belongs_to :room
  has_many :limitations, as: :limitable

  encrypts :name
end
