Rails.application.routes.draw do
  # get 'albums', to: 'albums#index'
  # get 'albums/new', to: 'albums#new', as: :new_album
  # post 'albums', to: 'albums#create'
  # get 'albums/show'
  # get 'albums/edit'
  # get 'albums/update'
  # get 'albums/destroy'
  # resources :albums, only: %i[index show new create edit update]
  resources :albums
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'albums#index'
end
