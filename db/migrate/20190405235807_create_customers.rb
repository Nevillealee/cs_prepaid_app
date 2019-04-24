# frozen_string_literal: true

class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
      # rails 5.1 >= primary key bigint by default
      # 'hash' in ReCharge API, renamed becuase of ruby reserved word conflict
      t.string :customer_hash
      t.string :email
      t.string :shopify_customer_id
      t.datetime :created_at
      t.datetime :updated_at
      t.string :first_name
      t.string :last_name
      t.string :billing_first_name
      t.string :billing_last_name
      # billing_address depreciated
      # billing_address2 depreciated
      # billing_zip depreciated
      # billing_city depreciated
      # billing_company depreciated
      # billing_province depreciated
      # billing_country depreciated
      # billing_phone depreciated
      # processor_type depreciated
      # status depreciated
      # has_valid_payment_method depreciated
      # reason_payment_method_not_valid depreciated
      t.boolean :has_card_error_in_dunning
      t.integer :number_subscriptions
      t.integer :number_active_subscriptions
      t.datetime :first_charge_processed_at
    end
  end
end
