require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      resources :products
      get '/cart', to: 'carts#show'
      post '/cart', to: 'carts#add_item'
      delete '/cart/:product_id', to: 'carts#remove_item'
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end