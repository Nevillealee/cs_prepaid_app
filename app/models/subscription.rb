class Subscription < ApplicationRecord
  belongs_to :customer
  belongs_to :address
  has_many :line_items
  has_many :orders, :through => :line_items
end
