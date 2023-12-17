# frozen_string_literal: true

require "ostruct"

class DashboardController < ApplicationController

  def index
    # dashboard tenants stats are slow, so let's cache them
    @output = Rails.cache.fetch("dashboard-tenant-stats", expires_in: 1.hour) do
      cache_stats
    end
  end

  private

  def cache_stats
    tenants = Tenant.includes(locations: {floors: {rooms: :desks}}).all
    
    users = User.all

    output = OpenStruct.new
    output.tenants = []
    tenants.each do |tenant|
      floors = 0
      rooms = 0
      desks = 0
      reservations_total = 0
      reservations_n7d = 0
      reservations_today = 0
      tenant.locations.each do |location|
        floors = floors + location.floors.length
        location.floors.each do |floor|
          rooms = rooms + floor.rooms.length
          floor.rooms.each do |room|
            desks = desks + room.desks.length
            room.desks.each do |desk|
              reservations_total = reservations_total + desk.reservations.where("start_date >= ?", DateTime.now.utc.beginning_of_day).length
              reservations_n7d = reservations_n7d + desk.reservations.where("start_date >= ?", DateTime.now.utc.beginning_of_day).where("end_date <= ?", DateTime.now.utc.end_of_day + 7.days).length
              reservations_today = reservations_today + desk.reservations.where("start_date >= ?", DateTime.now.utc.beginning_of_day).where("end_date <= ?", DateTime.now.utc.end_of_day).length
            end
          end
        end
      end

      output.tenants.push(
        {
          name: tenant.name,
          num_locations: tenant.locations.length,
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
