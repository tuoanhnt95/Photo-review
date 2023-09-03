class Review < ApplicationRecord
  has_many :photo_user_reviews
  has_many :photos, through: :photo_user_reviews
end
