# spec/factories/tags.rb
FactoryBot.define do
  factory :tag do
    association :post
    name { "test-tag" }
  end
end
