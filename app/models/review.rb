class Review < ApplicationRecord
  belongs_to :dynamic
  validates :rating, presence: true, inclusion: { in: 1..5 }
end