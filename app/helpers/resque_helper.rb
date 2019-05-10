module ResqueHelper
  # Returns an array of line_item.properties hashes
  # @params nested_hash [Hash] prop_params and  line_items of form data
  # @return [Hash] Recharge API formatted LineItem properties
  def format_params(nested_hash)
    my_props = nested_hash["prop_params"].map {|k,v| {"#{k}" => v}}
    my_line_items = nested_hash["line_items"]
    my_line_items["properties"] = my_props
    return my_line_items
  end

  def reformat_oline_items(prop_array)
    res = []
    prop_array.each do |l_item|
      new_line_item = {
        "properties" => l_item['properties'],
        "quantity" => l_item['quantity'].to_i,
        "sku" => l_item['sku'],
        "product_title" => l_item['title'],
        "variant_title" => l_item['variant_title'],
        "product_id" => l_item['shopify_product_id'].to_i,
        "variant_id" => l_item['shopify_variant_id'].to_i,
        "subscription_id" => l_item['subscription_id'].to_i,
        "price" => l_item['price'].to_i,
      }
      res.push(new_line_item)
    end
    res
  end
end
