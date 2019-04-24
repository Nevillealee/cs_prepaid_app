class ChangeRawLineItems < ActiveRecord::Migration[5.2]
  def change
    rename_column :orders, :raw_line_items, :line_items
  end
end
