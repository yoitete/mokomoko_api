class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :pillow_diagnoses, dependent: :destroy

  # フォロー関連
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "following_id",
                                   dependent: :destroy
  has_many :following, through: :active_relationships, source: :following
  has_many :followers, through: :passive_relationships, source: :follower

  # has_one_attached :profile_image  # 一時的にコメントアウト

  validates :firebase_uid, presence: true, uniqueness: true
  validates :name, presence: true
end
