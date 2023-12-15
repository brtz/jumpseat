class Tenant < ApplicationRecord
  self.implicit_order_column = :created_at

  validates :name, uniqueness: true
  
  # associations
  has_many :users, dependent: :destroy
  has_many :locations, dependent: :destroy
  
  encrypts :name
end
