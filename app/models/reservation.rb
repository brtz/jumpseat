class Reservation < ApplicationRecord
  self.implicit_order_column = :start_date

  validate :end_date_needs_to_be_same_day_as_start_date

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
end
