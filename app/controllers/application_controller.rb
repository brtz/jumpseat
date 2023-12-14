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
end
