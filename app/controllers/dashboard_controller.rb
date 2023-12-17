# frozen_string_literal: true
require "ostruct"

class DashboardController < ApplicationController

  def index
    # dashboard tenants stats are slow, so let's cache them
    @output = Rails.cache.fetch("dashboard-tenant-stats", expires_in: 1.hour) do
      CalcStatsJob.set(wait: 5.seconds).perform_later
      output = OpenStruct.new
      output.tenants = []
      output.tenants.push({
        name: "caching in progress",
        num_locations: 0,
        num_floors: 0,
        num_rooms: 0,
        num_desks: 0,
        num_reservations: {
          total: 0,
          n7d: 0,
          today: 0
        }
      })
      output
    end

    now = DateTime.now.utc

    todays_reservations = Reservation.where("start_date >= ?", now.beginning_of_day).where("end_date <= ?", now.end_of_day).load_async
    @in_today = []
    todays_reservations.each do |reservation|
      @in_today.push("#{reservation.user.first_name} #{reservation.user.last_name}")
    end

    tomorrows_reservations = Reservation.where("start_date >= ?", now.beginning_of_day + 1.day).where("end_date <= ?", now.end_of_day + 1.day).load_async
    @in_tomorrow = []
    tomorrows_reservations.each do |reservation|
      @in_tomorrow.push("#{reservation.user.first_name} #{reservation.user.last_name}")
    end
  end
end
