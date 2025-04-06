class Dynamic < ApplicationRecord
  has_many :reviews, dependent: :destroy

  def average_rating
    reviews.average(:rating)&.round(2) || 0
  end
end