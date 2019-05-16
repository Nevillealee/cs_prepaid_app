class Address < ApplicationRecord
  include Requestable

  belongs_to :customer, optional: true
  has_many :subscriptions
end
