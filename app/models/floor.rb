# frozen_string_literal: true

class Floor < ApplicationRecord
  self.implicit_order_column = :name

  scope :limit_location, ->(location) { where("location_id = ?", location.id) }

  validates :name, uniqueness: true
  validates :name, length: { in: 2..20 }
  validates :level, length: { in: 1..10 }

  # associations
  belongs_to :location, counter_cache: true
  has_many :rooms, dependent: :destroy
  has_many :limitations, as: :limitable

  encrypts :level
end
