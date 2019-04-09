class OrderLineItem < ApplicationRecord
  # Order.line_item abstraction
  belongs_to :order
  belongs_to :subscription
end
