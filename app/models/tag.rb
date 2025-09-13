class Tag < ApplicationRecord
  belongs_to :post
  validates :name, presence: true, length: { maximum: 50 }
  validates :name, uniqueness: { scope: :post_id, message: "この投稿には既に同じタグが存在します" }
end
