# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :destroy]
  before_action :access_granted, only: [:new, :edit, :create, :update, :destroy]

  # GET /rooms
  def index
    @rooms = Room.includes(floor: { location: :tenant }).order("name ASC").all.page(@page)
    respond_to do |format|
      format.html
      format.json { render json: Room.all }
    end
  end

  # GET /rooms/1
  def show
    params.permit(:id, :start_date)
    @start_date = DateTime.strptime(params["start_date"], "%Y-%m-%dT%H:%M").beginning_of_day
    end_date = @start_date.end_of_day

    desks = Desk.where("room_id = ?", @room.id).order("pos_x, pos_y ASC").all.load_async
    desk_ids = desks.map(&:id)
    reservations = Reservation.where(desk_id: desk_ids).where("start_date >= ?", @start_date).where("end_date <= ?", end_date).group(:desk_id).count

    @map = {}
    @map["width"] = 0
    @map["height"] = 0
    @map["desks"] = []
    desks.each do |desk|
      status = "available"
      status = "unavailable" if (!reservations[desk.id].nil?) && (reservations[desk.id] > 0)
      if status == "available"
        # try to validate a reservation
        reservation = Reservation.new(start_date: @start_date, end_date:, user: current_user, desk:)
        status = "unavailable" if !reservation.valid?
      end

      entry = {}
      entry["id"] = desk.id
      entry["name"] = desk.name
      entry["pos_x"] = desk.pos_x
      entry["pos_y"] = desk.pos_y
      entry["status"] = status

      @map["desks"].push(entry)

      @map["width"] = desk.pos_x if desk.pos_x >= @map["width"]
      @map["height"] = desk.pos_y if desk.pos_y >= @map["height"]
    end

    # we add one as a border here
    @map["width"] = @map["width"] + 1
    @map["height"] = @map["height"] + 1
    @map
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  def create
    @room = Room.new(room_params)

    if @room.save
      redirect_to rooms_path, notice: "Room was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /rooms/1
  def update
    if @room.update(room_params)
      redirect_to rooms_path, notice: "Room was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /rooms/1
  def destroy
    @room.destroy

    redirect_to rooms_url, notice: "Room was successfully deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def room_params
      params.require(:room).permit(:page, :name, :floor_id, limitation_ids: [])
    end

    def access_granted
      head(:forbidden) unless @current_role == "admin"
    end
end
