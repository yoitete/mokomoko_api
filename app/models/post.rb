class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :tags, dependent: :destroy
  accepts_nested_attributes_for :tags, allow_destroy: true
end
