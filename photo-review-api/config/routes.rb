Rails.application.routes.draw do
  # get 'albums/index'
  # get 'albums/new'
  # get 'albums/create'
  # get 'albums/show'
  # get 'albums/edit'
  # get 'albums/update'
  # get 'albums/destroy'
  resources :albums, only: [:new, :show, :edit]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
