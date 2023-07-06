class Photo < ApplicationRecord
  belongs_to :album
  has_many :photo_user_reviews, dependent: :destroy
  has_many :reviews, through: :photo_user_reviews

  # validates :name, presence: true
  # validates :url, presence: true
  # validates :album_id, presence: true
  # validates :review_id, presence: true
  validates :created_at, presence: true
  validates :updated_at, presence: true
end
