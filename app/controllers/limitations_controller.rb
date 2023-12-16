# frozen_string_literal: true

class LimitationsController < ApplicationController
  before_action :set_limitation, only: [:edit, :update, :destroy]
  before_action :access_granted
  after_action :queue_cleanup, only: [:create, :update, :destroy]

  # GET /limitations
  def index
    @limitations = Limitation.all.order("start_date ASC").page(@page)
    respond_to do |format|
      format.html
      format.json { render json: Limitation.all }
    end
  end

  # GET /limitations/new
  def new
    @limitation = Limitation.new
  end

  # GET /limitations/1/edit
  def edit
  end

  # POST /limitations
  def create
    patched_params = patch_params limitation_params

    @limitation = Limitation.new(patched_params)

    if @limitation.save
      redirect_to limitations_path, notice: "Limitation was successfully created."
    else
      puts limitation_params
      render :new
    end
  end

  # PATCH/PUT /limitations/1
  def update
    patched_params = patch_params limitation_params

    if @limitation.update(patched_params)
      redirect_to limitations_path, notice: "Limitation was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /limitations/1
  def destroy
    @limitation.destroy

    redirect_to limitations_url, notice: "Limitation was successfully deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_limitation
      @limitation = Limitation.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def limitation_params
      params.require(:limitation).permit(:page, :name, :start_date, :end_date)
    end

    def access_granted
      head(:forbidden) unless @current_role == "admin"
    end

    def queue_cleanup
      LimitationsCleanupJob.perform_later
    end
end
