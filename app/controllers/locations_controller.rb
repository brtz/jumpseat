# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action :set_location, only: [:edit, :update, :destroy]
  before_action :access_granted

  # GET /locations
  def index
    @locations = Location.includes([:tenant]).all.page(@page)
    respond_to do |format|
      format.html
      format.json { render json: Location.all }
    end
  end

  # GET /locations/new
  def new
    @location = Location.new
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations
  def create
    @location = Location.new(location_params)

    if @location.save
      redirect_to locations_path, notice: "Location was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /locations/1
  def update
    if @location.update(location_params)
      redirect_to locations_path, notice: "Location was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /locations/1
  def destroy
    @location.destroy

    redirect_to locations_url, notice: "Location was successfully deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def location_params
      params.require(:location).permit(:page, :name, :tenant_id, :street, :house_number, :zip_code, :city, :state, :country, limitation_ids: [])
    end

    def access_granted
      head(:forbidden) unless @current_role == "admin"
    end
end
