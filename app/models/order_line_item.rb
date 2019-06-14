class OrderLineItem < ApplicationRecord
  include Requestable

  # Order.line_item abstraction
  belongs_to :order
end
