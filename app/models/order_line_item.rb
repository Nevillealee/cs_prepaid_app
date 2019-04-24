# frozen_string_literal: true

class OrderLineItem < ApplicationRecord
  include Requestable

  # Order.line_item abstraction
  belongs_to :order
  belongs_to :subscription
end
