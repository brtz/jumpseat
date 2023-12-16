class Limitation < ApplicationRecord
  self.implicit_order_column = :start_date

  validates :name, uniqueness: true
  validates :name, length: { in: 2..50 }

  validates :start_date, comparison: { greater_than: DateTime.now.utc }
  validates :end_date, comparison: { greater_than: :start_date }

  belongs_to :limitable, polymorphic: true, optional: true
end
