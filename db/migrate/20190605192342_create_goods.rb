class CreateGoods < ActiveRecord::Migration[5.1]
  def change
    create_table :goods do |t|
      t.integer :micropost_id
      t.integer :created_by_id

      t.timestamps
    end
    add_index :goods, :micropost_id
    add_index :goods, :created_by_id
    add_index :goods, [:micropost_id, :created_by_id], unique: true
  end
end
