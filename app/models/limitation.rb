class Limitation < ApplicationRecord
  self.implicit_order_column = :start_date

  after_save :remove_stale_reservations

  validates :name, uniqueness: true
  validates :name, length: { in: 2..50 }

  validates :start_date, comparison: { greater_than: DateTime.now.utc }
  validates :end_date, comparison: { greater_than: :start_date }

  belongs_to :limitable, polymorphic: true, optional: true

  def remove_stale_reservations
    case limitable_type
    when "Tenant"
      reservations = Reservation.where("start_date >= ?", start_date).where("end_date <= ?", end_date)
      reservations.each do |reservation|
        desk = Desk.find_by(id: reservation.desk_id)
        reservation.destroy if desk.room.floor.location.tenant.id == limitable_id
      end
    when "Location"
      reservations = Reservation.where("start_date >= ?", start_date).where("end_date <= ?", end_date)
      reservations.each do |reservation|
        desk = Desk.find_by(id: reservation.desk_id)
        reservation.destroy if desk.room.floor.location.id == limitable_id
      end
    when "Floor"
      reservations = Reservation.where("start_date >= ?", start_date).where("end_date <= ?", end_date)
      reservations.each do |reservation|
        desk = Desk.find_by(id: reservation.desk_id)
        reservation.destroy if desk.room.floor.id == limitable_id
      end
    when "Room"
      reservations = Reservation.where("start_date >= ?", start_date).where("end_date <= ?", end_date)
      reservations.each do |reservation|
        desk = Desk.find_by(id: reservation.desk_id)
        reservation.destroy if desk.room.id == limitable_id
      end
    when "Desk"
      Reservation.where("start_date >= ?", start_date).where("end_date <= ?", end_date).where("desk_id = ?", limitable_id).destroy_all
    end
  end
end
