# config/routes.rb
Rails.application.routes.draw do
  require 'sidekiq/web'
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/health", to: "health#show"

  # Defines the root path route ("/")
  root "home#index"

  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }

  namespace :admin do
    resources :users
  end

  resources :projects do
    member do
      patch :deactivate_project
    end

    resources :tasks do
      member do
        patch :update_status
      end
      collection do
        get :search_task
      end
    end
  end

  resources :users do
    collection do
      get :search_user
    end
  end

  resources :tasks, only: [:index, :show] do
    post :add_dependency, to: 'task_dependencies#create'
  end

  get '/search', to: 'projects#search_project', as: :search_project

  # Admin-only routes for /tasks
  # authenticate :user, lambda { |u| u.admin? } do
  #   resources :tasks
  # end

  if Rails.env.development?
      authenticate :user, lambda { |u| u.admin? } do
        mount Sidekiq::Web => '/sidekiq'
        mount LetterOpenerWeb::Engine, at: "/letter_opener"
      end
  end
end
