require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  let(:valid_firebase_uid) { "test_firebase_uid_123" }
  let(:invalid_firebase_uid) { "invalid_firebase_uid" }
  let(:user) { create(:user, firebase_uid: valid_firebase_uid) }
  
  # モックJWTトークンを作成するヘルパー
  def create_mock_jwt_token(firebase_uid, issuer = "https://securetoken.google.com/mokomoko-2ac26")
    payload = {
      "iss" => issuer,
      "user_id" => firebase_uid,
      "exp" => Time.now.to_i + 3600
    }
    
    # 実際のJWTライブラリを使用してトークンを生成
    JWT.encode(payload, nil, 'none')
  end

  describe "POST /users" do
    context "with valid Firebase token" do
      it "creates a new user" do
        token = create_mock_jwt_token(valid_firebase_uid)
        
        expect {
          post "/users", params: { 
            name: "Test User", 
            token: token 
          }
        }.to change(User, :count).by(1)
        
        expect(response).to have_http_status(:created)
        
        user = User.last
        expect(user.firebase_uid).to eq(valid_firebase_uid)
        expect(user.name).to eq("Test User")
      end
    end

    context "with invalid Firebase token" do
      it "returns unprocessable entity" do
        post "/users", params: { 
          name: "Test User", 
          token: "invalid_token" 
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid token")
      end
    end

    context "with missing token" do
      it "returns unprocessable entity" do
        post "/users", params: { 
          name: "Test User" 
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid token")
      end
    end
  end

  describe "GET /posts/my" do
    context "with valid authentication" do
      it "returns user's posts" do
        user = create(:user, firebase_uid: valid_firebase_uid)
        create(:post, user: user, title: "My Post")
        
        token = create_mock_jwt_token(valid_firebase_uid)
        
        get "/posts/my", headers: { "Authorization" => "Bearer #{token}" }
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["posts"]).to be_an(Array)
        expect(json_response["posts"].length).to eq(1)
        expect(json_response["posts"][0]["title"]).to eq("My Post")
      end
    end

    context "with invalid authentication" do
      it "returns unauthorized" do
        get "/posts/my"
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
      end
    end

    context "with non-existent user" do
      it "returns unauthorized" do
        token = create_mock_jwt_token("non_existent_uid")
        
        get "/posts/my", headers: { "Authorization" => "Bearer #{token}" }
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
      end
    end

    context "with invalid token format" do
      it "returns unauthorized" do
        get "/posts/my", headers: { "Authorization" => "Bearer invalid_token" }
        
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
      end
    end
  end

  describe "GET /posts" do
    it "allows access without authentication" do
      create(:post, title: "Public Post")
      
      get "/posts"
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["posts"]).to be_an(Array)
      expect(json_response["posts"].length).to eq(1)
    end
  end

  describe "POST /posts" do
    context "with valid authentication" do
      it "creates a new post" do
        user = create(:user, firebase_uid: valid_firebase_uid)
        token = create_mock_jwt_token(valid_firebase_uid)
        
        expect {
          post "/posts", 
            params: { 
              post: { 
                title: "New Post", 
                price: 1000, 
                description: "Test description",
                season: "spring"
              } 
            },
            headers: { "Authorization" => "Bearer #{token}" }
        }.to change(Post, :count).by(1)
        
        expect(response).to have_http_status(:created)
        
        post = Post.last
        expect(post.title).to eq("New Post")
        expect(post.user_id).to eq(user.id)
      end
    end

    context "without authentication" do
      it "returns unauthorized" do
        post "/posts", params: { 
          post: { 
            title: "New Post", 
            price: 1000, 
            description: "Test description",
            season: "spring"
          } 
        }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
