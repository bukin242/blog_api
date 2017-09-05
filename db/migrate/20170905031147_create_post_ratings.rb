class CreatePostRatings < ActiveRecord::Migration[5.1]
  def change
    create_table :post_ratings do |t|
      t.references :post, foreign_key: true
      t.integer :rating_value, limit: 1
    end

    add_index :post_ratings, [:post_id, :rating_value]
  end
end
