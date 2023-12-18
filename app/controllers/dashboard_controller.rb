# frozen_string_literal: true
require "ostruct"

class DashboardController < ApplicationController

  def index
    # dashboard tenants stats are slow, so let's cache them
    @output = Rails.cache.fetch("dashboard/tenant-stats", expires_in: 1.hour) do
      calc_tenant_stats
    end

    now = DateTime.now.utc

    todays_reservations = Rails.cache.fetch("dashboard/todays-reservations", expires_in: 10.hour) do
      Reservation.shared(true).where("start_date >= ?", now.beginning_of_day).where("end_date <= ?", now.end_of_day).includes([:user])
    end
    @in_today = []
    todays_reservations.each do |reservation|
      @in_today.push("#{reservation.user.first_name} #{reservation.user.last_name}")
    end

    tomorrows_reservations = Rails.cache.fetch("dashboard/tomorrows-reservations", expires_in: 1.hour) do
      Reservation.shared(true).where("start_date >= ?", now.beginning_of_day + 1.day).where("end_date <= ?", now.end_of_day + 1.day).includes([:user])
    end
    @in_tomorrow = []
    tomorrows_reservations.each do |reservation|
      @in_tomorrow.push("#{reservation.user.first_name} #{reservation.user.last_name}")
    end

    @top5_users = Rails.cache.fetch("dashboard/top5-users-reservations", expires_in: 1.hour) do
      reservations = Reservation.shared(true).where("start_date >= ?", now.beginning_of_day).group(:user_id).order('count_all DESC').limit(5).count
      users = []
      i = 0
      reservations.each do |reservation|
        user = User.find_by(id: reservation[0])
        i = i + 1
        users.push("#{i}. #{user.first_name} #{user.last_name}: #{reservation[1]} reservations")
      end
      users
    end

    @top5_desks = Rails.cache.fetch("dashboard/top5-desks-reservations", expires_in: 1.hour) do
      reservations = Reservation.shared(true).where("start_date >= ?", now.beginning_of_day).group(:desk_id).order('count_all DESC').limit(5).count
      desks = []
      i = 0
      reservations.each do |reservation|
        desk = Desk.find_by(id: reservation[0])
        i = i + 1
        desks.push("#{i}. #{desk.name}: #{reservation[1]} reservations")
      end
      desks
    end
  end

  private

  def calc_tenant_stats
    tenants = Tenant.all.load_async

    now = DateTime.now.utc
    output = OpenStruct.new
    output.tenants = []

    tenants.each do |tenant|
      locations = Tenant.joins("INNER JOIN locations ON locations.tenant_id = tenants.id").
                    group("id").
                    where("tenants.id = ?", tenant.id).
                    count[tenant.id].
                    to_i

      floors = Tenant.joins("INNER JOIN locations ON locations.tenant_id = tenants.id").
                      joins("INNER JOIN floors ON floors.location_id = locations.id").
                      where("tenants.id = ?", tenant.id).
                      group("id").
                      count[tenant.id].
                      to_i

      rooms = Tenant.joins("INNER JOIN locations ON locations.tenant_id = tenants.id").
                joins("INNER JOIN floors ON floors.location_id = locations.id").
                joins("INNER JOIN rooms ON rooms.floor_id = floors.id").
                where("tenants.id = ?", tenant.id).
                group("id").
                count[tenant.id].
                to_i

      desks = Tenant.joins("INNER JOIN locations ON locations.tenant_id = tenants.id").
                joins("INNER JOIN floors ON floors.location_id = locations.id").
                joins("INNER JOIN rooms ON rooms.floor_id = floors.id").
                joins("INNER JOIN desks ON desks.room_id = rooms.id").
                where("tenants.id = ?", tenant.id).
                group("id").
                load_async.
                count[tenant.id].
                to_i

      reservations_total = Tenant.joins("INNER JOIN locations ON locations.tenant_id = tenants.id").
                            joins("INNER JOIN floors ON floors.location_id = locations.id").
                            joins("INNER JOIN rooms ON rooms.floor_id = floors.id").
                            joins("INNER JOIN desks ON desks.room_id = rooms.id").
                            joins("INNER JOIN reservations ON reservations.desk_id = desks.id").
                            group("id").
                            where("tenants.id = ?", tenant.id).
                            load_async.
                            count[tenant.id].
                            to_i

      reservations_n7d = Tenant.joins("INNER JOIN locations ON locations.tenant_id = tenants.id").
                          joins("INNER JOIN floors ON floors.location_id = locations.id").
                          joins("INNER JOIN rooms ON rooms.floor_id = floors.id").
                          joins("INNER JOIN desks ON desks.room_id = rooms.id").
                          joins("INNER JOIN reservations ON reservations.desk_id = desks.id").
                          group("id").
                          where("tenants.id = ?", tenant.id).
                          where("start_date >= ?", now.beginning_of_day).
                          where("end_date <= ?", now.end_of_day + 7.days).
                          load_async.
                          count[tenant.id].
                          to_i

      reservations_today = Tenant.joins("INNER JOIN locations ON locations.tenant_id = tenants.id").
                            joins("INNER JOIN floors ON floors.location_id = locations.id").
                            joins("INNER JOIN rooms ON rooms.floor_id = floors.id").
                            joins("INNER JOIN desks ON desks.room_id = rooms.id").
                            joins("INNER JOIN reservations ON reservations.desk_id = desks.id").
                            group("id").
                            where("tenants.id = ?", tenant.id).
                            where("start_date >= ?", now.beginning_of_day).
                            where("end_date <= ?", now.end_of_day).
                            load_async.
                            count[tenant.id].
                            to_i

      output.tenants.push(
        {
          name: tenant.name,
          num_locations: locations,
          num_floors: floors,
          num_rooms: rooms,
          num_desks: desks,
          num_reservations: {
            total: reservations_total,
            n7d: reservations_n7d,
            today: reservations_today
          }
        }
      )
    end

    output
  end
end
