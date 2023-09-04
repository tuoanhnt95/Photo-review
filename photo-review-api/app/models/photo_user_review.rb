class PhotoUserReview < ApplicationRecord
  belongs_to :photo
  belongs_to :user
  belongs_to :review
end
