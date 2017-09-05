class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.references :user, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.inet :ip
      t.decimal :avg_rating, :precision => 3, :scale => 2
    end

    add_index :posts, :avg_rating
  end
end
