class ReservationsCleanupJob < ApplicationJob
  queue_as :default

  def perform
    Reservation.where("end_date <= ?", DateTime.now.utc - 31.days).destroy_all
  end
end
