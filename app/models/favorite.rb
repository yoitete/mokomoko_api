class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # お気に入り追加時にカウントを増やす
  after_create :increment_favorites_count

  # お気に入り削除時にカウントを減らす
  after_destroy :decrement_favorites_count

  private

  def increment_favorites_count
    post.increment!(:favorites_count)
  end

  def decrement_favorites_count
    post.decrement!(:favorites_count)
  end
end
