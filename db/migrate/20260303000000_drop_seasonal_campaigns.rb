class DropSeasonalCampaigns < ActiveRecord::Migration[7.0]
  def up
    drop_table :seasonal_campaigns
  end

  def down
    create_table :seasonal_campaigns do |t|
      t.string :name, null: false
      t.text :description
      t.text :subtitle
      t.string :color_theme, null: false
      t.integer :start_month, null: false
      t.integer :end_month, null: false
      t.string :link_path, null: false
      t.string :button_text
      t.string :highlight_text
      t.string :highlight_color
      t.boolean :active, default: true
      t.string :campaign_type, default: "primary", null: false

      t.timestamps
    end
  end
end
