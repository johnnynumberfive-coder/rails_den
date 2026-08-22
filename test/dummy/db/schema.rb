# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_22_012320) do
  create_table "rails_den_administrators", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "user_type", null: false
    t.index ["user_type", "user_id"], name: "index_rails_den_administrators_on_user", unique: true
  end

  create_table "rails_den_boards", force: :cascade do |t|
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "enabled", default: true, null: false
    t.string "icon"
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "visibility", default: "public", null: false
    t.index ["category_id", "slug"], name: "index_rails_den_boards_on_category_id_and_slug", unique: true
    t.index ["category_id"], name: "index_rails_den_boards_on_category_id"
  end

  create_table "rails_den_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "enabled", default: true, null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "visibility", default: "public", null: false
    t.index ["slug"], name: "index_rails_den_categories_on_slug", unique: true
  end

  create_table "rails_den_posts", force: :cascade do |t|
    t.integer "author_id", null: false
    t.string "author_type", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.integer "deleted_by_id"
    t.string "deleted_by_type"
    t.integer "topic_id", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_rails_den_posts_on_author"
    t.index ["deleted_by_type", "deleted_by_id"], name: "index_rails_den_posts_on_deleted_by"
    t.index ["topic_id"], name: "index_rails_den_posts_on_topic_id"
  end

  create_table "rails_den_topics", force: :cascade do |t|
    t.integer "author_id", null: false
    t.string "author_type", null: false
    t.integer "board_id", null: false
    t.datetime "created_at", null: false
    t.boolean "locked", default: false, null: false
    t.boolean "pinned", default: false, null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_rails_den_topics_on_author"
    t.index ["board_id", "slug"], name: "index_rails_den_topics_on_board_id_and_slug", unique: true
    t.index ["board_id"], name: "index_rails_den_topics_on_board_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "rails_den_boards", "rails_den_categories", column: "category_id"
  add_foreign_key "rails_den_posts", "rails_den_topics", column: "topic_id"
  add_foreign_key "rails_den_topics", "rails_den_boards", column: "board_id"
  add_foreign_key "sessions", "users"
end
