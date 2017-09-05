class Post < ApplicationRecord
  belongs_to :user
  has_many :post_ratings, dependent: :destroy

  scope :rating_top, -> { where('avg_rating is not null').order('avg_rating desc') }
end
