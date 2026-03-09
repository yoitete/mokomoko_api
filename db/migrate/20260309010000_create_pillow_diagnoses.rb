class CreatePillowDiagnoses < ActiveRecord::Migration[8.0]
  def change
    create_table :pillow_diagnoses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :sleeping_position
      t.string :height
      t.string :material_preference
      t.string :order_interest
      t.string :price_range

      t.timestamps
    end
  end
end
