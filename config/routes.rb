# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :users, except: :show
  resources :tenants, except: :show
  resources :locations, except: :show
  resources :floors, except: :show
  resources :rooms
  resources :desks, except: :show
  resources :limitations, except: :show
  resources :reservations, except: :show

  get "profile" => "profiles#show"
  patch "profile" => "profiles#update"
  put "profile" => "profiles#update"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  # Defines the root path route ("/")
  root "dashboard#index"
end
