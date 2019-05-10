# 

class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      # rails 5.1 >= primary key bigint by default
      t.references :customer, foreign_key: true
      t.references :address, foreign_key: true
      t.bigint :charge_id
      t.string :transaction_id
      # shopify_id depreciated by ReCharge
      t.string :shopify_order_id
      t.bigint :shopify_order_number
      t.datetime :scheduled_at
      t.datetime :processed_at
      t.string :status
      # named 'type' on ReCharge but conflicts with rails
      t.string :order_type
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :payment_processor
      # address_is_active depreciated. omitted
      t.integer :is_prepaid
      t.jsonb :raw_line_items
      t.jsonb :shipping_address
      t.decimal :total_price, precision: 10, scale: 2
      t.jsonb :billing_address
      # shipping_date depreciated. omitted
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
