# frozen_string_literal: true

class FloorsController < ApplicationController
  before_action :set_floor, only: [:edit, :update, :destroy]
  before_action :access_granted

  # GET /floors
  def index
    @floors = Floor.includes(location: :tenant).order("name ASC").all.page(@page)
    respond_to do |format|
      format.html
      format.json { render json: Floor.all }
    end
  end

  # GET /floors/new
  def new
    @floor = Floor.new
  end

  # GET /floors/1/edit
  def edit
  end

  # POST /floors
  def create
    @floor = Floor.new(floor_params)

    if @floor.save
      redirect_to floors_path, notice: "Floor was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /floors/1
  def update
    if @floor.update(floor_params)
      redirect_to floors_path, notice: "Floor was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /floors/1
  def destroy
    @floor.destroy

    redirect_to floors_url, notice: "Floor was successfully deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_floor
      @floor = Floor.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def floor_params
      params.require(:floor).permit(:page, :name, :location_id, :level, limitation_ids: [])
    end

    def access_granted
      head(:forbidden) unless @current_role == "admin"
    end
end
