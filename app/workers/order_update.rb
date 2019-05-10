
class OrderUpdate
  @queue = "order_update"
  # extend ResqueHelper
  Resque.logger = Logger.new("#{Rails.root}/log/order_updates.log", 5, 10024000)
  Resque.logger.level = Logger::INFO

  def self.perform(params)
    Resque.logger.info "received params: #{params}"
    recharge_token = params["recharge_token"]
    recharge_change_header = {
      'X-Recharge-Access-Token' => recharge_token,
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    my_order_id = params[:order_id]
    new_line_items = format_params(params)
    item_array = []
    formatted_line_item = {
      "properties" => new_line_items['properties'],
      "quantity" => new_line_items['quantity'].to_i,
      "sku" => new_line_items['sku'],
      "title" => new_line_items['title'],
      "variant_title" => new_line_items['variant_title'],
      "product_id" => new_line_items['shopify_product_id'].to_i,
      "variant_id" => new_line_items['shopify_variant_id'].to_i,
      "subscription_id" => new_line_items['subscription_id'].to_i,
    }

    item_array.push(formatted_line_item)
    my_hash = { "line_items" => item_array }
    body = my_hash.to_json
    my_details = { "properties" => item_array }

    # When updating line_items, you need to provide all the data that was in
    # line_items before, otherwise only new parameters will remain! (from Recharge docs)
    recharge_response = HTTParty.put("https://api.rechargeapps.com/orders/#{my_order_id}", :headers => recharge_change_header, :body => body, :timeout => 80)
    Resque.logger.info "Recharge Response: #{recharge_response.inspect}"
    Resque.logger.info "Recharge Response: #{recharge_response.code}"
  end
end
