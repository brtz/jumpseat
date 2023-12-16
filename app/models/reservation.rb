class Reservation < ApplicationRecord
  self.implicit_order_column = :start_date

  validate :end_date_needs_to_be_same_day_as_start_date
  validate :user_has_required_position
  validate :users_reservations_quota, on: :create

  validates :start_date, comparison: { greater_than: DateTime.now.utc }
  validates :start_date, comparison: { less_than: DateTime.now.utc + 1.month }
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
end
