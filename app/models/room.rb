# frozen_string_literal: true

class Room < ApplicationRecord
  self.implicit_order_column = :name

  scope :limit_floor, ->(floor) { where("floor_id = ?", floor.id) }

  validates :name, uniqueness: true
  validates :name, length: { in: 2..20 }

  # associations
  belongs_to :floor, counter_cache: true
  has_many :desks, dependent: :destroy
  has_many :limitations, as: :limitable
end
