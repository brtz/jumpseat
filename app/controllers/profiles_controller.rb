# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :set_profile

  # GET /profile
  def profile
  end

  # PATCH/PUT /profile
  def update
    if @profile.update(profile_params)
      redirect_to profile_path, notice: "Your profile was successfully updated."
    else
      render :edit
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = current_user
    end

    # Only allow a trusted parameter "white list" through.
    def profile_params
      params.require(:user).permit(:page, :first_name, :middle_name, :last_name, :tenant_id)
    end
end
