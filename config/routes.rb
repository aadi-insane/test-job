# config/routes.rb
Rails.application.routes.draw do
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"

  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }

  namespace :admin do
    resources :users
  end

  resources :projects do
    resources :tasks
  end

  resources :tasks, only: [:index, :show]
  
end
