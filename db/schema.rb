# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170905031147) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "post_ratings", force: :cascade do |t|
    t.bigint "post_id"
    t.integer "rating_value", limit: 2
    t.index ["post_id", "rating_value"], name: "index_post_ratings_on_post_id_and_rating_value"
    t.index ["post_id"], name: "index_post_ratings_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title", null: false
    t.text "description", null: false
    t.inet "ip"
    t.decimal "avg_rating", precision: 3, scale: 2
    t.index ["avg_rating"], name: "index_posts_on_avg_rating"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "user_post_ips", force: :cascade do |t|
    t.bigint "users_ids", array: true
    t.inet "ip"
    t.index ["ip"], name: "index_user_post_ips_on_ip", unique: true
    t.index ["users_ids"], name: "index_user_post_ips_on_users_ids", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.string "login", null: false
    t.index ["login"], name: "index_users_on_login", unique: true
  end

  add_foreign_key "post_ratings", "posts"
  add_foreign_key "posts", "users"
end
