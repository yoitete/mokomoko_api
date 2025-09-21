class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :tags, dependent: :destroy
  has_many :favorites, dependent: :destroy
  accepts_nested_attributes_for :tags, allow_destroy: true

  # 人気順スコープ
  scope :popular, -> { order(favorites_count: :desc, created_at: :desc) }
end
