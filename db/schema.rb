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

ActiveRecord::Schema.define(version: 2019_04_24_182730) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.bigint "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "province"
    t.string "country"
    t.string "first_name"
    t.string "last_name"
    t.string "zip"
    t.string "company"
    t.string "phone"
    t.string "cart_note"
    t.jsonb "note_attributes"
    t.jsonb "shipping_lines_override"
    t.integer "discount_id"
    t.index ["customer_id"], name: "index_addresses_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "email"
    t.string "shopify_customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "first_name"
    t.string "last_name"
    t.boolean "has_card_error_in_dunning"
    t.integer "number_subscriptions"
    t.integer "number_active_subscriptions"
    t.datetime "first_charge_processed_at"
    t.string "status"
  end

  create_table "order_line_items", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "subscription_id"
    t.integer "grams"
    t.string "price"
    t.integer "quantity"
    t.bigint "shopify_product_id"
    t.bigint "shopify_variant_id"
    t.jsonb "properties"
    t.string "product_title"
    t.string "vendor"
    t.string "sku"
    t.string "variant_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_line_items_on_order_id"
    t.index ["subscription_id"], name: "index_order_line_items_on_subscription_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "address_id"
    t.bigint "charge_id"
    t.string "transaction_id"
    t.string "shopify_order_id"
    t.bigint "shopify_order_number"
    t.datetime "scheduled_at"
    t.datetime "processed_at"
    t.string "status"
    t.string "order_type"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "payment_processor"
    t.integer "is_prepaid"
    t.jsonb "line_items"
    t.jsonb "shipping_address"
    t.decimal "total_price", precision: 10, scale: 2
    t.jsonb "billing_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["address_id"], name: "index_orders_on_address_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "address_id"
    t.bigint "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "next_charge_scheduled_at"
    t.datetime "cancelled_at"
    t.string "product_title"
    t.string "variant_title"
    t.decimal "price", precision: 10, scale: 2
    t.integer "quantity"
    t.string "status"
    t.bigint "shopify_variant_id"
    t.bigint "shopify_product_id"
    t.bigint "recharge_product_id"
    t.string "sku"
    t.boolean "sku_override"
    t.string "order_interval_unit"
    t.string "order_interval_frequency"
    t.string "charge_interval_frequency"
    t.integer "order_day_of_month"
    t.integer "order_day_of_week"
    t.jsonb "properties"
    t.integer "expire_after_specific_number_of_charges"
    t.string "cancellation_reason"
    t.string "cancellation_reason_comments"
    t.integer "max_retries_reached"
    t.integer "has_queued_charges"
    t.index ["address_id"], name: "index_subscriptions_on_address_id"
    t.index ["customer_id"], name: "index_subscriptions_on_customer_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.boolean "admin", default: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "password_changed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "addresses", "customers"
  add_foreign_key "order_line_items", "orders"
  add_foreign_key "order_line_items", "subscriptions"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "customers"
  add_foreign_key "subscriptions", "addresses"
  add_foreign_key "subscriptions", "customers"
end
