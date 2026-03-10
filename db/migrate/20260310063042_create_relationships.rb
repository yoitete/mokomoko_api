class CreateRelationships < ActiveRecord::Migration[8.0]
  def change
    create_table :relationships do |t|
      t.bigint :follower_id, null: false
      t.bigint :following_id, null: false

      t.timestamps
    end

    add_index :relationships, :follower_id
    add_index :relationships, :following_id
    add_index :relationships, [ :follower_id, :following_id ], unique: true
    add_foreign_key :relationships, :users, column: :follower_id
    add_foreign_key :relationships, :users, column: :following_id
  end
end
