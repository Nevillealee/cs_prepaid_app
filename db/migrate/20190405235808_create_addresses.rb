#

class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.references :customer, foreign_key: false
      t.datetime :created_at
      t.datetime :updated_at
      t.string :address1
      t.string :address2
      t.string :city
      t.string :province
      t.string :country
      t.string :first_name
      t.string :last_name
      t.string :zip
      t.string :company
      t.string :phone
      t.string :cart_note
      t.jsonb :note_attributes
      # original_shipping_lines depreciated
      t.jsonb :shipping_lines_override
      t.integer :discount_id
    end
  end
end
