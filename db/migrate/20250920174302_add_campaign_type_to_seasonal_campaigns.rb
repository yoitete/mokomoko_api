class AddCampaignTypeToSeasonalCampaigns < ActiveRecord::Migration[8.0]
  def change
    add_column :seasonal_campaigns, :campaign_type, :string, default: 'primary', null: false
    add_index :seasonal_campaigns, :campaign_type
    add_index :seasonal_campaigns, [:campaign_type, :active]
  end
end
