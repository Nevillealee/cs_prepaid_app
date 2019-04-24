# frozen_string_literal: true

class Address < ApplicationRecord
  include Requestable

  belongs_to :customer
  has_many :subscriptions
end
