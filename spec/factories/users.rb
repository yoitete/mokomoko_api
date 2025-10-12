# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    firebase_uid { "firebase_uid_#{SecureRandom.hex(8)}" }
    name { "Test User" }
    nickname { "testuser" }
    bio { "This is a test user" }
    selected_icon { "user" }
  end
end
