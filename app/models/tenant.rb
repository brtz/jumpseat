# frozen_string_literal: true

class Tenant < ApplicationRecord
  self.implicit_order_column = :name

  validates :name, uniqueness: true

  # associations
  has_many :users, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :limitations, as: :limitable
end
