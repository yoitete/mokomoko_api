class AddPillowAttributesToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :material, :string
    add_column :posts, :sleeping_position, :string
    add_column :posts, :height, :string
  end
end
