require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "is invalid without firebase_uid" do
      user = build(:user, firebase_uid: nil)
      expect(user).not_to be_valid
    end

    it "is invalid with duplicate firebase_uid" do
      create(:user, firebase_uid: "duplicate_uid")
      user = build(:user, firebase_uid: "duplicate_uid")
      expect(user).not_to be_valid
    end
  end

  describe "associations" do
    it "has many posts" do
      user = create(:user)
      post1 = create(:post, user: user)
      post2 = create(:post, user: user)
      
      expect(user.posts).to include(post1, post2)
    end

    it "has many favorites" do
      user = create(:user)
      post = create(:post)
      favorite = create(:favorite, user: user, post: post)
      
      expect(user.favorites).to include(favorite)
    end

    it "destroys associated posts when user is destroyed" do
      user = create(:user)
      post = create(:post, user: user)
      
      expect { user.destroy }.to change(Post, :count).by(-1)
    end

    it "destroys associated favorites when user is destroyed" do
      user = create(:user)
      post = create(:post)
      favorite = create(:favorite, user: user, post: post)
      
      expect { user.destroy }.to change(Favorite, :count).by(-1)
    end
  end
end
