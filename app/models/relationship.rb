class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :following, class_name: "User"

  validates :follower_id, uniqueness: { scope: :following_id, message: "既にフォローしています" }
  validate :cannot_follow_self

  after_create :increment_counts
  after_destroy :decrement_counts

  private

  def cannot_follow_self
    errors.add(:follower_id, "自分自身をフォローすることはできません") if follower_id == following_id
  end

  def increment_counts
    follower.increment!(:following_count)
    following.increment!(:followers_count)
  end

  def decrement_counts
    follower.decrement!(:following_count)
    following.decrement!(:followers_count)
  end
end
