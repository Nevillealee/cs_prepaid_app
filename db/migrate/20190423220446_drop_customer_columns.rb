class DropCustomerColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :customers, :billing_first_name
    remove_column :customers, :billing_last_name
    remove_column :customers, :customer_hash
  end
end
