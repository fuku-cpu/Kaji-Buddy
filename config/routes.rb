Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "chore_list_entries#index", as: :authenticated_root
  end 

  devise_scope :user do
    root "devise/sessions#new"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  resources :chores, only: %i[index new create show edit update destroy]
  resources :chore_records, only: %i[index create destroy]
  resources :chore_list_entries, only: %i[index new create destroy] do
    get :guide, on: :collection
  end
end
