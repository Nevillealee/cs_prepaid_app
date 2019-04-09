class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :address, foreign_key: true
      t.references :customer, foreign_key: true
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :next_charge_scheduled_at
      t.datetime :cancelled_at
      t.string :product_title
      t.string :variant_title
      t.decimal :price, scale: 10, precision: 2
      t.integer :quantity
      t.string :status
      t.bigint :shopify_variant_id
      t.bigint :shopify_product_id
      t.bigint :recharge_product_id
      t.string :sku
      t.boolean :sku_override
      t.string :order_interval_unit
      t.string :order_interval_frequency
      t.string :charge_interval_frequency
      t.integer :order_day_of_month
      t.integer :order_day_of_week
      t.jsonb :properties
      t.integer :expire_after_specific_number_of_charges
      t.string :cancellation_reason
      t.string :cancellation_reason_comment
      t.integer :max_retries_reached
      t.integer :has_queued_charges
      t.boolean :commit_update
    end
  end
end
