class User < ApplicationRecord
  has_many :pets
  accepts_nested_attributes_for :pets, limit: 3
end
