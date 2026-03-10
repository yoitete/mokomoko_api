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

  # コメント関連のルート
  get "/comments" => "comments#index"
  post "/comments" => "comments#create"
  delete "/comments/:id" => "comments#destroy"

  # フォロー関連のルート
  post "/relationships" => "relationships#create"
  delete "/relationships" => "relationships#destroy"
  get "/relationships/check" => "relationships#check"
  get "/relationships/followers" => "relationships#followers"
  get "/relationships/following" => "relationships#following"

  # 枕診断関連のルート
  get "/pillow_diagnoses" => "pillow_diagnoses#index"
  post "/pillow_diagnoses" => "pillow_diagnoses#create"
  delete "/pillow_diagnoses/:id" => "pillow_diagnoses#destroy"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
