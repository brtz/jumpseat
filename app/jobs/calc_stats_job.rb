require "ostruct"

class CalcStatsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    tenants = Tenant.includes(locations: {floors: {rooms: :desks}}).all
    now = DateTime.now.utc
    
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
              reservations_total = reservations_total + desk.reservations.where("start_date >= ?", now.beginning_of_day).load_async.length
              reservations_n7d = reservations_n7d + desk.reservations.where("start_date >= ?", now.beginning_of_day).where("end_date <= ?", now.end_of_day + 7.days).load_async.length
              reservations_today = reservations_today + desk.reservations.where("start_date >= ?", now.beginning_of_day).where("end_date <= ?", now.end_of_day).load_async.length
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

    Rails.cache.delete("dashboard/tenant-stats")
    Rails.cache.fetch("dashboard/tenant-stats", expires_in: 1.hour) do
      output
    end
  end
end
