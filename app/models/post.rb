class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :tags, dependent: :destroy
  has_many :favorites, dependent: :destroy
  accepts_nested_attributes_for :tags, allow_destroy: true

  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, presence: true
  validates :season, presence: true

  # 人気順スコープ
  scope :popular, -> { order(favorites_count: :desc, created_at: :desc) }
end
