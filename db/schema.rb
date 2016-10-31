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

ActiveRecord::Schema.define(version: 20161031032341) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "anons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.integer  "creator_id", null: false
    t.string   "first_name", null: false
    t.integer  "pizzas",     null: false
    t.string   "vendor",     null: false
    t.string   "video",      null: false
    t.integer  "donor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_requests_on_creator_id", using: :btree
  end

  create_table "thank_yous", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.bigint   "fb_userID",                 null: false
    t.string   "first_name",                null: false
    t.string   "signup_email",              null: false
    t.string   "current_email",             null: false
    t.integer  "rating",        default: 0
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

end
