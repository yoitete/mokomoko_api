class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :favorites, dependent: :destroy
  # has_one_attached :profile_image  # 一時的にコメントアウト

  validates :firebase_uid, presence: true, uniqueness: true
  validates :name, presence: true
end
