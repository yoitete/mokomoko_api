# spec/factories/seasonal_campaigns.rb
FactoryBot.define do
  factory :seasonal_campaign do
    name { "Test Campaign" }
    description { "This is a test campaign" }
    subtitle { "Test Subtitle" }
    color_theme { "red" }
    start_month { 1 }
    end_month { 3 }
    link_path { "/test-campaign" }
    button_text { "詳しくはこちら →" }
    highlight_text { "Highlight Text" }
    highlight_color { "#FF0000" }
    active { true }
    campaign_type { "primary" }
  end
end
