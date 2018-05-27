Rails.application.routes.draw do
  scope path: "/v1/api" do
    # User routes
    resources :users, except: [:show]
    get  "users/current" => "users#current"
    post "users/token"   => "user_token#create"

    # Shift routes
    resources :shifts
  end
end
