# frozen_string_literal: true

class Order < ApplicationRecord
  include Requestable

  has_many :order_line_items
  # i.e. order contains multiple recurring subscriptions purchased at once
  has_many :subscriptions, through: :order_line_items
  belongs_to :customer
  belongs_to :address

  def sizes(sub_id)
    line_items.each do |item|
      if item["subscription_id"].to_s == sub_id
      return item["properties"].select{|p| Subscription::SIZE_PROPERTIES.include? p['name'] }
      .map{|p| [p['name'], p['value']]}
      .to_h
      end
    end
  end

  def sizes_change(new_sizes, sub_id)
    line_items.each do |item|
      if item["subscription_id"].to_s == sub_id
        prop_hash = item["properties"].map{|prop| [prop['name'], prop['value']]}.to_h
        merged_hash = prop_hash.merge new_sizes
        puts "merged_hash = #{merged_hash}"
        item["properties"] = merged_hash.map{|k, v| {'name' => k, 'value' => v}}
      end
    end
  end
end
