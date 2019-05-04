module ResqueHelper
  # Returns an array of line_item.properties hashes
  def format_params(nested_hash)
    my_props = nested_hash[:prop_params].map {|k,v| {"#{k}" => v}}
    my_line_items = nested_hash[:line_items]
    my_line_items["properties"] = my_props
    return my_line_items
  end
end
