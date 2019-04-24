# frozen_string_literal: true

class Customer < ApplicationRecord
  include Requestable

  has_many :subscriptions
  has_many :addresses
  has_many :orders
end
