require 'rails_helper'

RSpec.describe "Users API", type: :request do
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

  describe "GET /users" do
    let!(:user1) { create(:user, name: "User 1") }
    let!(:user2) { create(:user, name: "User 2") }

    it "returns all users" do
      get "/users"

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.length).to eq(2)
    end
  end

  describe "GET /users/:id" do
    it "returns the user" do
      get "/users/#{user.id}"

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(user.id)
      expect(json_response["name"]).to eq(user.name)
    end

    it "returns 404 for non-existent user" do
      get "/users/99999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /users/by_firebase_uid/:firebase_uid" do
    it "returns the user by firebase_uid" do
      get "/users/by_firebase_uid/#{user.firebase_uid}"

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["firebase_uid"]).to eq(user.firebase_uid)
    end

    it "returns 404 for non-existent firebase_uid" do
      get "/users/by_firebase_uid/non_existent_uid"

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("User not found")
    end
  end

  describe "POST /users" do
    let(:new_firebase_uid) { "new_firebase_uid_123" }
    let(:token) { create_mock_jwt_token(new_firebase_uid) }

    it "creates a new user" do
      expect {
        post "/users", params: {
          name: "New User",
          token: token
        }
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)

      user = User.last
      expect(user.firebase_uid).to eq(new_firebase_uid)
      expect(user.name).to eq("New User")
    end

    it "validates required fields" do
      post "/users", params: {
        name: "",
        token: token
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PUT /users/:id" do
    let(:token) { create_mock_jwt_token(valid_firebase_uid) }

    it "updates user profile" do
      put "/users/#{user.id}",
          params: {
            profile: {
              nickname: "Updated Nickname",
              bio: "Updated bio",
              selected_icon: "cat"
            }
          },
          headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)

      user.reload
      expect(user.nickname).to eq("Updated Nickname")
      expect(user.bio).to eq("Updated bio")
      expect(user.selected_icon).to eq("cat")
    end

    it "updates user info" do
      put "/users/#{user.id}",
          params: {
            user: {
              name: "Updated Name",
              nickname: "Updated Nickname"
            }
          },
          headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)

      user.reload
      expect(user.name).to eq("Updated Name")
      expect(user.nickname).to eq("Updated Nickname")
    end
  end
end
