class Subscription < ApplicationRecord
  include Requestable

  belongs_to :customer
  belongs_to :address
  has_many :line_items
  has_many :orders, :through => :order_line_items
end
