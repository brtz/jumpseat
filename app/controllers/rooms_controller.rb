# frozen_string_literal: true

class RoomsController < ApplicationController
  before_action :set_room, only: [:edit, :update, :destroy]
  before_action :access_granted

  # GET /rooms
  def index
    @rooms = Room.includes([:floor]).all.page(@page)
    respond_to do |format|
      format.html
      format.json { render json: Room.all }
    end
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
      params.require(:room).permit(:page, :name, :floor_id, :limitation_ids => [])
    end

    def access_granted
      head(:forbidden) unless @current_role == "admin"
    end
end