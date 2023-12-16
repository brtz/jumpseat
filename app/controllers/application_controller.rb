# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }
  before_action :authenticate_user!
  before_action :define_role
  before_action :define_page

  def index
  end

  private
    def define_page
      @page = params[:page] unless params[:page].nil?
    end

    def define_role
      if current_user.nil?
        @current_role = nil
      else
        case current_user.admin
        when true
          @current_role = "admin"
        else
          @current_role = "user"
        end
      end
    end

    def patch_params(params)
      patched_params = params
      patched_params["start_date"] = DateTime.strptime(params["start_date"], "%Y-%m-%dT%H:%M").beginning_of_day.to_s
      if params["end_date"].nil?
        patched_params["end_date"] = DateTime.strptime(params["start_date"], "%Y-%m-%dT%H:%M").end_of_day.to_s
      else
        patched_params["end_date"] = DateTime.strptime(params["end_date"], "%Y-%m-%dT%H:%M").end_of_day.to_s
      end
      patched_params
    end
end
