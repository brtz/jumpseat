# frozen_string_literal: true

class ReservationsController < ApplicationController
  before_action :set_reservation, only: [:edit, :update, :destroy]
  before_action :access_granted

  # GET /reservations
  def index
    @reservations = Reservation.includes([:desk, :user]).all.order("start_date ASC").page(@page)
    respond_to do |format|
      format.html
      format.json { render json: Reservation.all }
    end
  end

  # GET /reservations/new
  def new
    @reservation = Reservation.new
  end

  # GET /reservations/1/edit
  def edit
  end

  # POST /reservations
  def create
    patched_params = patch_params reservation_params

    @reservation = Reservation.new(patched_params)

    if @reservation.save
      redirect_to reservations_path, notice: "Reservation was successfully created."
    else
      puts reservation_params
      render :new
    end
  end

  # PATCH/PUT /reservations/1
  def update
    patched_params = patch_params reservation_params

    if @reservation.update(patched_params)
      redirect_to reservations_path, notice: "Reservation was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /reservations/1
  def destroy
    @reservation.destroy

    redirect_to reservations_url, notice: "Reservation was successfully deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def reservation_params
      params.require(:reservation).permit(:page, :name, :start_date, :user_id, :desk_id)
    end

    def access_granted
      head(:forbidden) unless @current_role == "admin"
    end

    def patch_params(params)
      patched_params = params
      patched_params["start_date"] = DateTime.strptime(params["start_date"], "%Y-%m-%dT%H:%M").beginning_of_day.to_s
      patched_params["end_date"] = DateTime.strptime(params["start_date"], "%Y-%m-%dT%H:%M").end_of_day.to_s
      patched_params
    end
end
