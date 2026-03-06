class ChangeDescriptionToTextInPosts < ActiveRecord::Migration[8.0]
  def change
    change_column :posts, :description, :text
  end
end
