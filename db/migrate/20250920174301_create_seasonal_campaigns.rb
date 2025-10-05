class CreateSeasonalCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :seasonal_campaigns do |t|
      t.string :name, null: false
      t.text :description
      t.text :subtitle
      t.string :color_theme, default: 'red'
      t.integer :start_month, null: false
      t.integer :end_month, null: false
      t.string :link_path, null: false
      t.string :button_text, default: '詳しくはこちら →'
      t.text :highlight_text
      t.string :highlight_color
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :seasonal_campaigns, [ :start_month, :end_month ]
    add_index :seasonal_campaigns, :active
  end
end
