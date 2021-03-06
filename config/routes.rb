# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  mount RailsEventStore::Browser => '/res' if Rails.env.development?

  resource :seat_reservation do
    get :index
    get :new
    post :create
    get :user_input
    post :add_passenger
    get :payment_confirm
    post :payment_done
    get :congratulate
  end
end
