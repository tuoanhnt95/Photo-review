Rails.application.routes.draw do
  resources :reviews
  resources :albums do
    resources :photos, only: %i[index create]
  end
  resources :photos, only: %i[show update destroy] do
    resources :photo_user_reviews, only: %i[index create]
  end
  get '/photos/:photo_id/get_review', to: 'photo_user_reviews#show_by_photo_and_use', as: 'reviews_by_photo_and_user'
  devise_for :users
end

# TODO: Add a route to get all reviews for a photo
