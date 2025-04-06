class Dynamic < ApplicationRecord
  has_many :reviews, dependent: :destroy

 
end