# frozen_string_literal: true

class Tenant < ApplicationRecord
  self.implicit_order_column = :created_at

  validates :name, uniqueness: true

  # associations
  has_many :users, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :floors, dependent: :destroy

  encrypts :name
end
