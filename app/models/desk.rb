# frozen_string_literal: true

class Desk < ApplicationRecord
  self.implicit_order_column = :name

  scope :limit_room, ->(room) { where("room_id = ?", room.id) }

  validate :position_in_room_unique

  validates :name, uniqueness: true
  validates :name, length: { in: 2..20 }
  validates :pos_x, comparison: { greater_than: 0 }
  validates :pos_y, comparison: { greater_than: 0 }
  validates :required_position, inclusion: { in: %w(trainee apprentice employee lead management), message: "%{value} is not a valid position" }

  # associations
  belongs_to :room, counter_cache: true
  has_many :limitations, as: :limitable
  has_many :reservations, dependent: :destroy

  def position_in_room_unique
    if id.nil?
      desks_with_same_pos = Desk.where("room_id = ?", room_id).where("pos_x = ?", pos_x).where("pos_y = ?", pos_y).all.count
    else
      desks_with_same_pos = Desk.where("id != ?", id).where("room_id = ?", room_id).where("pos_x = ?", pos_x).where("pos_y = ?", pos_y).all.count
    end
    errors.add(:pos_x, "position in room not unique / overlapping") if desks_with_same_pos > 0
  end
end
