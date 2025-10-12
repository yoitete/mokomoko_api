# spec/factories/posts.rb
FactoryBot.define do
  factory :post do
    association :user
    title { "Test Post" }
    price { 1000 }
    description { "This is a test post" }
    season { "spring" }
    favorites_count { 0 }
  end
end
