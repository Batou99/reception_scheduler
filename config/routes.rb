Rails.application.routes.draw do
  root "shifts#index"

  get "auth" => "shifts#auth"

  post "user_token" => "user_token#create"

  resources :users, except: [:show]
  resources :shifts

  get "users/current" => "users#current"
end
