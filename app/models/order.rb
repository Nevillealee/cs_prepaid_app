# frozen_string_literal: true

class Order < ApplicationRecord
  include Requestable
  
  has_many :line_items
  # i.e. order contains multiple recurring subscriptions purchased at once
  has_many :subscriptions, through: :order_line_items
  belongs_to :customer
  belongs_to :address
end
