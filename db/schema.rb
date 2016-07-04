# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160704191201) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_trgm"

  create_table "chapters", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description"
    t.integer  "number"
    t.integer  "story_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "image"
    t.date     "date_from"
    t.date     "date_to"
  end

  add_index "chapters", ["story_id"], name: "index_chapters_on_story_id", using: :btree

  create_table "chapters_nodes", id: false, force: :cascade do |t|
    t.integer "chapter_id", null: false
    t.integer "node_id",    null: false
  end

  add_index "chapters_nodes", ["chapter_id", "node_id"], name: "index_chapters_nodes_on_chapter_id_and_node_id", unique: true, using: :btree

  create_table "chapters_relations", id: false, force: :cascade do |t|
    t.integer "chapter_id",  null: false
    t.integer "relation_id", null: false
  end

  add_index "chapters_relations", ["chapter_id", "relation_id"], name: "index_chapters_relations_on_chapter_id_and_relation_id", unique: true, using: :btree

  create_table "datasets", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "visualization_id"
    t.hstore   "node_custom_fields",     default: [],              array: true
    t.hstore   "relation_custom_fields", default: [],              array: true
  end

  add_index "datasets", ["visualization_id"], name: "index_datasets_on_visualization_id", unique: true, using: :btree

  create_table "galleries", force: :cascade do |t|
    t.integer  "visualization_ids", default: [],              array: true
    t.integer  "story_ids",         default: [],              array: true
    t.integer  "user_ids",          default: [],              array: true
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "nodes", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "visible",       default: true
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "node_type"
    t.integer  "dataset_id"
    t.string   "image"
    t.hstore   "custom_fields"
  end

  add_index "nodes", ["custom_fields"], name: "index_nodes_on_custom_fields", using: :gist
  add_index "nodes", ["dataset_id"], name: "index_nodes_on_dataset_id", using: :btree

  create_table "relations", force: :cascade do |t|
    t.string   "relation_type"
    t.integer  "source_id"
    t.integer  "target_id"
    t.date     "from"
    t.date     "to"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "dataset_id"
    t.boolean  "direction",     default: false
    t.hstore   "custom_fields"
  end

  add_index "relations", ["custom_fields"], name: "index_relations_on_custom_fields", using: :gist
  add_index "relations", ["dataset_id"], name: "index_relations_on_dataset_id", using: :btree

  create_table "stories", force: :cascade do |t|
    t.text     "name"
    t.integer  "author_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.text     "description"
    t.boolean  "published"
    t.integer  "visualization_id"
    t.string   "image"
  end

  add_index "stories", ["author_id"], name: "index_stories_on_author_id", using: :btree
  add_index "stories", ["name"], name: "index_stories_on_name", using: :gin, opclasses: {"name"=>"gin_trgm_ops"}
  add_index "stories", ["visualization_id"], name: "index_stories_on_visualization_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                   default: "", null: false
    t.string   "website"
    t.string   "facebook"
    t.string   "twitter"
    t.string   "avatar"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "visualizations", force: :cascade do |t|
    t.text     "name"
    t.text     "description"
    t.boolean  "published"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "author_id"
    t.text     "parameters"
  end

  add_index "visualizations", ["author_id"], name: "index_visualizations_on_author_id", using: :btree
  add_index "visualizations", ["name"], name: "index_visualizations_on_name", using: :gin, opclasses: {"name"=>"gin_trgm_ops"}

  add_foreign_key "chapters", "stories"
end
