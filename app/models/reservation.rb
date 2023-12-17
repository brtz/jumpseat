class Reservation < ApplicationRecord
  self.implicit_order_column = :start_date

  scope :shared, ->(bool) { where("shared = ?", bool) }

  validate :end_date_needs_to_be_same_day_as_start_date
  validate :user_has_required_position
  validate :honor_limitations
  validate :unique_reservation
  validate :users_reservations_quota, on: :create
  validate :users_reservations_per_day

  validates :start_date, comparison: { greater_than: DateTime.now.utc }
  validates :start_date, comparison: { less_than: DateTime.now.utc + 3.month }
  validates :end_date, comparison: { greater_than: :start_date }
  
  belongs_to :desk
  belongs_to :user

  def end_date_needs_to_be_same_day_as_start_date
    if end_date > start_date.end_of_day
      errors.add(:end_date, "cannot be beyond start date's end of day")
    end
  end

  def users_reservations_quota
    user = User.find_by(id: user_id)
    users_reservations_count = Reservation.where("user_id=?", user_id).where("start_date >= ?", DateTime.now.utc).count

    if users_reservations_count >= user.quota_max_reservations
      errors.add(:user_id, "max reservations quota reached (#{users_reservations_count} / #{user.quota_max_reservations})")
    end
  end

  def user_has_required_position
    positions = {}
    positions["trainee"] = 0
    positions["apprentice"] = 1
    positions["employee"] = 2
    positions["lead"] = 3
    positions["management"] = 4

    user = User.find_by(id: user_id)
    desk = Desk.find_by(id: desk_id)

    user_position = positions[user.current_position]
    desk_position = positions[desk.required_position]

    if user_position < desk_position
      errors.add(:desk_id, "requires higher position to be reserved (#{desk.required_position})")
    end
  end

  def honor_limitations
    user = User.find_by(id: user_id)
    desk = Desk.find_by(id: desk_id)
    limitations = Limitation.all.load_async

    matched_limitations = []

    # break on hit would be faster, however the user would have to go through limitations one by one then
    limitations.each do |limitation|
      if start_date.between?(limitation.start_date, limitation.end_date)
        case limitation.limitable_type
        when "Tenant"
          matched_limitations.push(limitation.name) if desk.room.floor.location.tenant.id == limitation.limitable_id
        when "Location"
          matched_limitations.push(limitation.name) if desk.room.floor.location.id == limitation.limitable_id
        when "Floor"
          matched_limitations.push(limitation.name) if desk.room.floor.id == limitation.limitable_id
        when "Room"
          matched_limitations.push(limitation.name) if desk.room.id == limitation.limitable_id
        when "Desk"
          matched_limitations.push(limitation.name) if desk.id == limitation.limitable_id
        end
      end
    end

    errors.add(:start_date, "matching limitations found: #{matched_limitations.join(", ")}") if matched_limitations.size > 0
  end

  def unique_reservation
    if id.nil?
      errors.add(:desk_id, "already reserved") if Reservation.where("desk_id = ?", desk_id).where("start_date >= ?", start_date.beginning_of_day).where("end_date <= ?", end_date.end_of_day).count > 0
    else
      errors.add(:desk_id, "already reserved") if Reservation.where("desk_id = ?", desk_id).where("start_date >= ?", start_date.beginning_of_day).where("end_date <= ?", end_date.end_of_day).where("id != ?", id).count > 0
    end
  end

  def users_reservations_per_day
    if id.nil?
      errors.add(:start_date, "cannot reserve more than one desk per day") if Reservation.where("user_id = ?", user_id).where("start_date >= ?", start_date.beginning_of_day).where("end_date <= ?", end_date.end_of_day).count > 0
    else
      errors.add(:start_date, "cannot reserve more than one desk per day") if Reservation.where("user_id = ?", user_id).where("start_date >= ?", start_date.beginning_of_day).where("end_date <= ?", end_date.end_of_day).where("id != ?", id).count > 0
    end
  end
end
