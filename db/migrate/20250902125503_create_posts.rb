class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.integer :price
      t.string :description
      t.string :season

      t.timestamps
    end
  end
end
