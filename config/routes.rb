Rails.application.routes.draw do
  # resources :favorites
  # resources :tags
  # resources :posts
  # resources :users
  # users#indexは、users_controllerのindexアクション
  get "/users" => "users#index"
  post "/users" => "users#create"
  get "/users/:id" => "users#show"
  get "/users/by_firebase_uid/:firebase_uid" => "users#show_by_firebase_uid"
  put "/users/:id" => "users#update"
  patch "/users/:id" => "users#update"
  get "/posts" => "posts#index"
  get "/posts/my" => "posts#my"
  get "/posts/popular" => "posts#popular"
  get "/posts/:id" => "posts#show"
  post "/posts" => "posts#create"
  put "/posts/:id" => "posts#update"
  patch "/posts/:id" => "posts#update"
  delete "/posts/:id" => "posts#destroy"

  # お気に入り関連のルート
  get "/favorites" => "favorites#index"
  post "/favorites" => "favorites#create"
  delete "/favorites" => "favorites#destroy"
  get "/favorites/check" => "favorites#check"
  
  # 季節特集関連のルート
  get "/seasonal_campaigns/current" => "seasonal_campaigns#current"
  get "/seasonal_campaigns/current_secondary" => "seasonal_campaigns#current_secondary"
  get "/seasonal_campaigns/for_month/:month" => "seasonal_campaigns#for_month"
  get "/seasonal_campaigns/active" => "seasonal_campaigns#active"
  get "/seasonal_campaigns" => "seasonal_campaigns#index"
  get "/seasonal_campaigns/:id" => "seasonal_campaigns#show"
  post "/seasonal_campaigns" => "seasonal_campaigns#create"
  put "/seasonal_campaigns/:id" => "seasonal_campaigns#update"
  patch "/seasonal_campaigns/:id" => "seasonal_campaigns#update"
  delete "/seasonal_campaigns/:id" => "seasonal_campaigns#destroy"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
