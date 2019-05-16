class Order < ApplicationRecord
  include Requestable

  has_many :order_line_items
  # i.e. order contains multiple recurring subscriptions purchased at once
  has_many :subscriptions, through: :order_line_items
  belongs_to :customer, optional: true
  belongs_to :address, optional: true
  SIZE_PROPERTIES = ['leggings', 'tops', 'sports-jacket', 'sports-bra', 'gloves'].freeze

  # Converts line item properties into hash 'product_type' => 'size' pairs
  # @param sub_id [Integer] associated subscription id of Order
  # @return [Hash] Order sizes
  def sizes(sub_id)
    idx = 0
    line_items.each_with_index do |item, i|
      if item["subscription_id"] == sub_id
        idx = i
        break
      end
    end
    return line_items[idx]["properties"].select{|p| SIZE_PROPERTIES.include? p['name'] }
    .map{|p| [p['name'], p['value']]}.to_h
  end

  # Changes Order sizes locally
  # @note Converts line_item properties array of hashes with 'name'=> k and 'value'=> v
  # #note into single hash with k (name keys value) => v (value keys value).
  # @note Merges single hash  with new_sizes arg hash.
  # @note {"sports-bra"=>"L", "tops"=>"L", "leggings"=>"L", "sports-jacket" => "L"}
  # @note Finally converts single hash back into array of hashes with 'name' => ?, 'value' => ? pairs
  # @param new_sizes [Hash] order sizes
  def sizes_change(new_sizes, sub_id)
    idx = 0
    line_items.each_with_index do |item, i|
      if item["subscription_id"] == sub_id
        idx = i
        break
      end
    end
    prop_hash = line_items[idx]["properties"].map{|prop| [prop['name'], prop['value']]}.to_h
    merged_hash = prop_hash.merge new_sizes
    line_items[idx]["properties"] = merged_hash.map{|k, v| {'name' => k, 'value' => v}}
  end
end
