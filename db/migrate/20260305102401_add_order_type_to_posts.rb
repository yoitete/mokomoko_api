class AddOrderTypeToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :order_type, :string
  end
end
