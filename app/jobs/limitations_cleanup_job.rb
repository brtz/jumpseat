class LimitationsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Limitation.where("end_date <= ?", DateTime.now.utc).destroy_all
  end
end
