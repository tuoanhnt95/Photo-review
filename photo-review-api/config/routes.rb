Rails.application.routes.draw do
  resources :uploads
  resources :reviews
  resources :albums do
    resources :photos, only: %i[index create]
  end
  resources :photos, only: %i[show update destroy] do
    resources :photo_user_reviews, only: %i[index create]
  end
  resources :photo_user_reviews, only: %i[show destroy]
  get '/photos/:photo_id/get_review', to: 'photo_user_reviews#show_by_photo_and_user', as: 'reviews_by_photo_and_user'
  put '/photos/:photo_id/photo_user_reviews', to: 'photo_user_reviews#update', as: 'update_review'
  get '/albums/:album_id/upload_progress', to: 'uploads#show_progress', as: 'upload_progress'
  devise_for :users
end

# TODO: Add a route to get all reviews for a photo
