Rails.application.routes.draw do
  get "timer/start"
  get "timer/stop"
  get "dashboard/show"
  resources :time_entries
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check


  #Only logged-in users can access the app
  authenticated :user do
    root to: "dashboard#show", as: :authenticated_root
    resources :time_entries
    post "timer/start", to: "timer#start", as: :start_timer
    post "timer/stop",  to: "timer#stop",  as: :stop_timer
  end

  #If not logged in, send to sign in
  root to: redirect("/users/sign_in")
end
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
