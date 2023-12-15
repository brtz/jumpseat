# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :access_granted

  # GET /users
  def index
    @users = User.includes([:tenant]).all.page(@page)
    respond_to do |format|
      format.html
      format.json { render json: User.all }
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: "User was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to users_path, notice: "User was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    return head(:conflict) if @user.id == @current_user.id

    @user.destroy
    redirect_to users_url, notice: "User was successfully deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:page, :email, :password, :first_name, :middle_name, :last_name, :current_position, :admin)
    end

    def access_granted
      head(:forbidden) unless @current_role == "admin"
    end
end
