Rails.application.routes.draw do
  resources :photo_user_reviews
  resources :reviews
  resources :albums do
    resources :photos, only: %i[index create]
  end
  resources :photos, only: %i[show update destroy]
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
end
