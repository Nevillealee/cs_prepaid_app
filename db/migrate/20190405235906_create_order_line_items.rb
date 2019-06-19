#

class CreateOrderLineItems < ActiveRecord::Migration[5.2]
  def change
    # Order.line_item abstraction
    create_table :order_line_items do |t|
      t.references :order, foreign_key: false
      t.references :subscription, foreign_key: false
      t.integer :grams
      t.string :price
      t.integer :quantity
      t.bigint :shopify_product_id
      t.bigint :shopify_variant_id
      t.jsonb :properties
      # title depreciated
      t.string :product_title
      t.string :vendor
      t.string :sku
      t.string :variant_title
      t.timestamps
    end
  end
end
