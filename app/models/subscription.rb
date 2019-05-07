# frozen_string_literal: true

class Subscription < ApplicationRecord
  include Requestable

  belongs_to :customer
  belongs_to :address
  has_many :line_items
  has_many :orders, through: :order_line_items

  SIZE_PROPERTIES = ['leggings', 'tops', 'sports-jacket', 'sports-bra', 'gloves'].freeze
  SIZE_VALUES = %w[XS S M L XL].freeze
end
