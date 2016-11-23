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

ActiveRecord::Schema.define(version: 20161123002921) do

  create_table "java_files", force: :cascade do |t|
    t.string   "path_file"
    t.text     "content"
    t.boolean  "compile"
    t.integer  "count_operators"
    t.float    "cl"
    t.integer  "deepness"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "chep",            default: false
    t.integer  "spens"
    t.string   "role"
    t.float    "chep_metric"
  end

end
