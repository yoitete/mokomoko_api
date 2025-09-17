Rails.application.routes.draw do
  # resources :favorites
  # resources :tags
  # resources :posts
  # resources :users
  # users#indexは、users_controllerのindexアクション
  get "/users" => "users#index"
  post "/users" => "users#create"
  get "/posts" => "posts#index"
  get "/posts/:id" => "posts#show"
  post "/posts" => "posts#create"

  # お気に入り関連のルート
  get "/favorites" => "favorites#index"
  post "/favorites" => "favorites#create"
  delete "/favorites" => "favorites#destroy"
  get "/favorites/check" => "favorites#check"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
