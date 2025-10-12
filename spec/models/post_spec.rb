require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      post = build(:post)
      expect(post).to be_valid
    end

    it "is invalid without user" do
      post = build(:post, user: nil)
      expect(post).not_to be_valid
    end

    it "is invalid without title" do
      post = build(:post, title: nil)
      expect(post).not_to be_valid
    end

    it "is invalid without price" do
      post = build(:post, price: nil)
      expect(post).not_to be_valid
    end

    it "is invalid with negative price" do
      post = build(:post, price: -100)
      expect(post).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to user" do
      user = create(:user)
      post = create(:post, user: user)

      expect(post.user).to eq(user)
    end

    it "has many tags" do
      post = create(:post)
      tag1 = create(:tag, post: post, name: "tag1")
      tag2 = create(:tag, post: post, name: "tag2")

      expect(post.tags).to include(tag1, tag2)
    end

    it "has many favorites" do
      post = create(:post)
      user1 = create(:user)
      user2 = create(:user)
      favorite1 = create(:favorite, post: post, user: user1)
      favorite2 = create(:favorite, post: post, user: user2)

      expect(post.favorites).to include(favorite1, favorite2)
    end

    it "destroys associated tags when post is destroyed" do
      post = create(:post)
      tag = create(:tag, post: post)

      expect { post.destroy }.to change(Tag, :count).by(-1)
    end

    it "destroys associated favorites when post is destroyed" do
      post = create(:post)
      user = create(:user)
      favorite = create(:favorite, post: post, user: user)

      expect { post.destroy }.to change(Favorite, :count).by(-1)
    end
  end

  describe "scopes" do
    let!(:post1) { create(:post, season: "spring", favorites_count: 5) }
    let!(:post2) { create(:post, season: "summer", favorites_count: 10) }
    let!(:post3) { create(:post, season: "autumn", favorites_count: 0) }

    describe ".popular" do
      it "returns posts ordered by favorites_count" do
        popular_posts = Post.popular
        expect(popular_posts).to include(post1, post2, post3)
        expect(popular_posts.first.favorites_count).to be >= popular_posts.last.favorites_count
      end
    end
  end
end
