require 'rails_helper'

RSpec.describe "Posts API", type: :request do
  let(:user) { create(:user) }
  let(:valid_firebase_uid) { user.firebase_uid }
  
  # モックJWTトークンを作成するヘルパー
  def create_mock_jwt_token(firebase_uid)
    payload = {
      "iss" => "https://securetoken.google.com/mokomoko-2ac26",
      "user_id" => firebase_uid,
      "exp" => Time.now.to_i + 3600
    }
    JWT.encode(payload, nil, 'none')
  end

  describe "GET /posts" do
    let!(:post1) { create(:post, title: "Spring Post", season: "spring") }
    let!(:post2) { create(:post, title: "Summer Post", season: "summer") }
    let!(:post3) { create(:post, title: "Autumn Post", season: "autumn") }

    it "returns all posts" do
      get "/posts"
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["posts"]).to be_an(Array)
      expect(json_response["posts"].length).to eq(3)
    end

    it "supports pagination" do
      get "/posts", params: { page: 1, per_page: 2 }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["posts"].length).to eq(2)
      expect(json_response["pagination"]["current_page"]).to eq(1)
      expect(json_response["pagination"]["per_page"]).to eq(2)
    end

    it "filters by season" do
      get "/posts", params: { season: "spring" }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["posts"].length).to eq(1)
      expect(json_response["posts"][0]["season"]).to eq("spring")
    end

    it "supports search functionality" do
      get "/posts", params: { search: "Spring" }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["posts"].length).to eq(1)
      expect(json_response["posts"][0]["title"]).to eq("Spring Post")
    end

    it "supports sorting by popularity" do
      post1.update!(favorites_count: 5)
      post2.update!(favorites_count: 10)
      
      get "/posts", params: { sort: "popular" }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["posts"][0]["favorites_count"]).to eq(10)
    end
  end

  describe "GET /posts/my" do
    let(:token) { create_mock_jwt_token(valid_firebase_uid) }
    let!(:user_post1) { create(:post, user: user, title: "My Post 1") }
    let!(:user_post2) { create(:post, user: user, title: "My Post 2") }
    let!(:other_post) { create(:post, title: "Other Post") }

    it "returns only user's posts" do
      get "/posts/my", headers: { "Authorization" => "Bearer #{token}" }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["posts"].length).to eq(2)
      expect(json_response["posts"].map { |p| p["title"] }).to contain_exactly("My Post 1", "My Post 2")
    end

    it "supports pagination" do
      get "/posts/my", 
          params: { page: 1, per_page: 1 },
          headers: { "Authorization" => "Bearer #{token}" }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["posts"].length).to eq(1)
      expect(json_response["pagination"]["current_page"]).to eq(1)
      expect(json_response["pagination"]["per_page"]).to eq(1)
    end
  end

  describe "GET /posts/popular" do
    let!(:popular_post1) { create(:post, title: "Very Popular", favorites_count: 10) }
    let!(:popular_post2) { create(:post, title: "Somewhat Popular", favorites_count: 5) }
    let!(:unpopular_post) { create(:post, title: "Not Popular", favorites_count: 0) }

    it "returns only posts with favorites" do
      get "/posts/popular"
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(2)
      expect(json_response.map { |p| p["title"] }).to contain_exactly("Very Popular", "Somewhat Popular")
    end

    it "supports season filtering" do
      popular_post1.update!(season: "spring")
      popular_post2.update!(season: "summer")
      
      get "/posts/popular", params: { season: "spring" }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response[0]["season"]).to eq("spring")
    end

    it "supports limit parameter" do
      get "/posts/popular", params: { limit: 1 }
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
    end
  end

  describe "POST /posts" do
    let(:token) { create_mock_jwt_token(valid_firebase_uid) }
    let(:valid_params) do
      {
        post: {
          title: "New Post",
          price: 1500,
          description: "This is a new post",
          season: "spring",
          tags: ["test", "example"]
        }
      }
    end

    it "creates a new post" do
      expect {
        post "/posts", 
             params: valid_params,
             headers: { "Authorization" => "Bearer #{token}" }
      }.to change(Post, :count).by(1)
      
      expect(response).to have_http_status(:created)
      
      post = Post.last
      expect(post.title).to eq("New Post")
      expect(post.user_id).to eq(user.id)
      expect(post.tags.pluck(:name)).to contain_exactly("test", "example")
    end

    it "validates required fields" do
      invalid_params = { post: { title: "" } }
      
      post "/posts", 
           params: invalid_params,
           headers: { "Authorization" => "Bearer #{token}" }
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PUT /posts/:id" do
    let(:token) { create_mock_jwt_token(valid_firebase_uid) }
    let!(:post) { create(:post, user: user, title: "Original Title") }

    it "updates the post" do
      put "/posts/#{post.id}",
          params: { 
            post: { 
              title: "Updated Title",
              description: "Updated description"
            } 
          },
          headers: { "Authorization" => "Bearer #{token}" }
      
      expect(response).to have_http_status(:ok)
      
      post.reload
      expect(post.title).to eq("Updated Title")
      expect(post.description).to eq("Updated description")
    end

    it "prevents updating other user's posts" do
      other_user = create(:user)
      other_post = create(:post, user: other_user)
      
      put "/posts/#{other_post.id}",
          params: { 
            post: { 
              title: "Hacked Title"
            } 
          },
          headers: { "Authorization" => "Bearer #{token}" }
      
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /posts/:id" do
    let(:token) { create_mock_jwt_token(valid_firebase_uid) }
    let!(:post) { create(:post, user: user) }

    it "deletes the post" do
      expect {
        delete "/posts/#{post.id}",
               headers: { "Authorization" => "Bearer #{token}" }
      }.to change(Post, :count).by(-1)
      
      expect(response).to have_http_status(:ok)
    end

    it "prevents deleting other user's posts" do
      other_user = create(:user)
      other_post = create(:post, user: other_user)
      
      expect {
        delete "/posts/#{other_post.id}",
               headers: { "Authorization" => "Bearer #{token}" }
      }.not_to change(Post, :count)
      
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
