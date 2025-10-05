require 'rails_helper'

RSpec.describe "Application", type: :request do
  describe "GET /users" do
    it "returns a successful response" do
      get "/users"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /posts" do
    it "returns a successful response" do
      get "/posts"
      expect(response).to have_http_status(:ok)
    end
  end
end
