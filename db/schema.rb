# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_08_23_154556) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "email"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "credit_cents", default: 0, null: false
    t.string "credit_currency", default: "AED", null: false
    t.bigint "debit_cents", default: 0, null: false
    t.string "debit_currency", default: "AED", null: false
    t.string "encrypted_password", default: "", null: false
    t.index ["email"], name: "index_accounts_on_email"
    t.index ["phone_number"], name: "index_accounts_on_phone_number"
    t.index ["status"], name: "index_accounts_on_status"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resource_type", "resource_id"], name: "index_sessions_on_resource_type_and_resource_id"
    t.index ["token"], name: "index_sessions_on_token", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "account_id"
    t.integer "type", null: false
    t.bigint "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "AED", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "sender_id"
    t.bigint "receiver_id"
    t.integer "event", default: 0, null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["receiver_id"], name: "index_transactions_on_receiver_id"
    t.index ["sender_id"], name: "index_transactions_on_sender_id"
  end

  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "accounts", column: "receiver_id"
  add_foreign_key "transactions", "accounts", column: "sender_id"
end
