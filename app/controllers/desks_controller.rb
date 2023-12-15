# frozen_string_literal: true

class DesksController < ApplicationController
  before_action :set_desk, only: [:edit, :update, :destroy]
  before_action :access_granted

  # GET /desks
  def index
    @desks = Desk.includes([:room]).all.page(@page)
    respond_to do |format|
      format.html
      format.json { render json: Desk.all }
    end
  end

  # GET /desks/new
  def new
    @desk = Desk.new
  end

  # GET /desks/1/edit
  def edit
  end

  # POST /desks
  def create
    @desk = Desk.new(desk_params)

    if @desk.save
      redirect_to desks_path, notice: "Desk was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /desks/1
  def update
    if @desk.update(desk_params)
      redirect_to desks_path, notice: "Desk was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /desks/1
  def destroy
    @desk.destroy

    redirect_to desks_url, notice: "Desk was successfully deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_desk
      @desk = Desk.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def desk_params
      params.require(:desk).permit(:page, :name, :room_id, :pos_x, :pos_y, :width, :height, :required_position)
    end

    def access_granted
      head(:forbidden) unless @current_role == "admin"
    end
end
