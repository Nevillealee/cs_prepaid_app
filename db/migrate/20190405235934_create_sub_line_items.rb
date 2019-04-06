class CreateSubLineItems < ActiveRecord::Migration[5.2]
  def change
    create_table :sub_line_items do |t|

      t.timestamps
    end
  end
end
