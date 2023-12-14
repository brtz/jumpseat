class Tenant < ApplicationRecord
  self.implicit_order_column = :created_at

  validates :name, uniqueness: true
  
  # associations
  has_many :users, dependent: :destroy
  
  encrypts :name
end
