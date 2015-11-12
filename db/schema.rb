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

ActiveRecord::Schema.define(version: 20151112120452) do

  create_table "datasets", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "visualization_id"
  end

  add_index "datasets", ["visualization_id"], name: "index_datasets_on_visualization_id"

  create_table "nodes", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "visible"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "node_type"
    t.integer  "dataset_id"
  end

  add_index "nodes", ["dataset_id"], name: "index_nodes_on_dataset_id"

  create_table "relations", force: :cascade do |t|
    t.string   "relation_type"
    t.integer  "source_id"
    t.integer  "target_id"
    t.date     "from"
    t.date     "to"
    t.date     "at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "dataset_id"
  end

  add_index "relations", ["dataset_id"], name: "index_relations_on_dataset_id"

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
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "visualizations", force: :cascade do |t|
    t.text     "name"
    t.text     "description"
    t.boolean  "published"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
