class Subscription < ApplicationRecord
  include Requestable
  has_paper_trail
  belongs_to :customer, optional: true
  belongs_to :address, optional: true
  has_many :line_items
  has_many :orders, through: :order_line_items

  SIZE_PROPERTIES = ['leggings', 'tops', 'sports-jacket', 'sports-bra', 'gloves'].freeze

  def sizes=(new_sizes)
    prop_hash = properties.map{|prop| [prop['name'], prop['value']]}.to_h
    merged_hash = prop_hash.merge(new_sizes)
    self[:properties] = merged_hash.map{|k, v| {'name' => k, 'value' => v}}
  end

  def sizes
    #returns hash of (size_property and size) key-value pairs with keys as symbols
    properties
      .select{|p| SIZE_PROPERTIES.include? p['name']}
      .map{|p| [p['name'], p['value']]}
      .to_h
  end
end
