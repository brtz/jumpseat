# frozen_string_literal: true

class ReservationsController < ApplicationController
  before_action :set_reservation, only: [:edit, :update, :destroy]
  before_action :access_granted, only: [:edit, :update, :destroy]
  after_action :queue_cleanup, only: [:create, :update, :destroy]

  # GET /reservations
  def index
    if current_user.admin?
      @reservations = Reservation.includes([:desk, :user]).all.order("start_date ASC").page(@page)
    else
      @reservations = Reservation.limit_user(current_user.id).includes([:desk, :user]).order("start_date ASC").page(@page)
    end
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

    if (@current_role != "admin") && (patched_params["user_id"] != current_user.id)
      head(:forbidden)
      return
    end

    # quick reservation
    if patched_params["desk_id"].nil?
      # the .to_a is important, as we do not want to call .delete on the collection of Desks
      available_desks = Desk.includes(room: { floor: { location: :tenant } }).all.order("RANDOM()").load_async.to_a
      available_desks.delete_if { |desk| desk.room.floor.location.tenant.id != current_user.tenant.id }

      if available_desks.size > 0
        available_desks.each do |desk|
          # try to save
          patched_params["desk_id"] = desk.id
          @reservation = Reservation.new(patched_params)
          if @reservation.save
            redirect_to root_path, notice: "Created new quick reservation."
            return
          end
        end
        # we have tried every desk, and found none saving successfully
        redirect_to root_path, alert: "Could not find a suitable desk for quick reservation. Please select manually."
        return
      else
        redirect_to root_path, alert: "Could not find a suitable desk for quick reservation. Please select manually."
        return
      end
    end

    @reservation = Reservation.new(patched_params)

    if @reservation.save
      redirect_to reservations_path, notice: "Reservation was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /reservations/1
  def update
    patched_params = patch_params reservation_params

    if (@current_role != "admin") && (patched_params["user_id"] != current_user.id)
      head(:forbidden)
      return
    end

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
      params.require(:reservation).permit(:page, :name, :start_date, :user_id, :desk_id, :shared)
    end

    def access_granted
      if (@current_role != "admin") && (@reservation.user_id != current_user.id)
        head(:forbidden)
      end
    end

    def queue_cleanup
      ReservationsCleanupJob.perform_later
    end
end
