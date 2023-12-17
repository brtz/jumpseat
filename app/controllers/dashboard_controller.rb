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

    todays_reservations = Rails.cache.fetch("dashboard-todays-reservations", expires_in: 1.hour) do
      Reservation.where("start_date >= ?", now.beginning_of_day).where("end_date <= ?", now.end_of_day).includes([:user])
    end
    @in_today = []
    todays_reservations.each do |reservation|
      @in_today.push("#{reservation.user.first_name} #{reservation.user.last_name}")
    end

    tomorrows_reservations = Rails.cache.fetch("dashboard-tomorrows-reservations", expires_in: 1.hour) do
      Reservation.where("start_date >= ?", now.beginning_of_day + 1.day).where("end_date <= ?", now.end_of_day + 1.day).includes([:user])
    end
    @in_tomorrow = []
    tomorrows_reservations.each do |reservation|
      @in_tomorrow.push("#{reservation.user.first_name} #{reservation.user.last_name}")
    end

    top5_users_reservations = Rails.cache.fetch("dashboard-top5-users-reservations", expires_in: 1.hour) do
      Reservation.where("start_date >= ?", now.beginning_of_day).group(:user_id).order('count_all DESC').limit(5).count
    end
    @top5_users = []
    i = 0
    top5_users_reservations.each do |reservation|
      user = User.find_by(id: reservation[0])
      if !user.nil?
        i = i + 1
        @top5_users.push("#{i}. #{user.first_name} #{user.last_name}: #{reservation[1]} reservations")
      else
        # we've found a user that doesn't exist any more, invalidate cache
        Rails.cache.delete("dashboard-top5-users-reservations")
      end
    end

    top5_desks_reservations = Rails.cache.fetch("dashboard-top5-desks-reservations", expires_in: 1.hour) do
      Reservation.where("start_date >= ?", now.beginning_of_day).group(:desk_id).order('count_all DESC').limit(5).count
    end
    @top5_desks = []
    i = 0
    top5_desks_reservations.each do |reservation|
      desk = Desk.find_by(id: reservation[0])
      if !desk.nil?
        i = i + 1
        @top5_desks.push("#{i}. #{desk.name}: #{reservation[1]} reservations")
      else
        # we've found a desk that doesn't exist any more, invalidate cache
        Rails.cache.delete("dashboard-top5-desks-reservations")
      end
    end
  end
end
