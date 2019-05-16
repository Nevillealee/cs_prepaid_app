class OrderLineItem < ApplicationRecord
  include Requestable

  # Order.line_item abstraction
  belongs_to :order, optional: true
  belongs_to :subscription, optional: true
end
