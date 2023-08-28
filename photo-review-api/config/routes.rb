Rails.application.routes.draw do
  resources :photo_user_reviews
  resources :reviews
  resources :albums do
    resources :photos
  end
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
end
