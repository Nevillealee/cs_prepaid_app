require Rails.root.join('app', 'helpers','resque_helper.rb')

# Class for  updating Subscription and attached QUEUED Order sizes
# @param arg [Hash] nested hash (prop_params and  line_items) of form data
class LineItemUpdate
  include ResqueHelper

  def initialize(arg)
    @form_data = arg
    recharge_token = arg["recharge_token"]
    @recharge_change_header = {
      'X-Recharge-Access-Token' => recharge_token,
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  def run
    Resque.logger = Logger.new("#{Rails.root}/log/order_updates.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    Resque.logger.info "received params: #{@form_data}"

    order_id = @form_data["order_id"].to_i
    my_order = Order.find(order_id)
    new_line_items = format_params(@form_data)
    item_array = []

    formatted_line_item = {
      "properties" => new_line_items['properties'].reduce({}, :update).map{|k, v| {'name' => k, 'value' => v}},
      "quantity" => new_line_items['quantity'].to_i,
      "sku" => new_line_items['sku'],
      "product_title" => new_line_items['title'],
      "variant_title" => new_line_items['variant_title'],
      "product_id" => new_line_items['shopify_product_id'].to_i,
      "variant_id" => new_line_items['shopify_variant_id'].to_i,
      "subscription_id" => new_line_items['subscription_id'].to_i,
      "price" => new_line_items['price'].to_i
    }
    item_array.push(formatted_line_item)
    Resque.logger.warn "LINE_ITEMS BEFORE UPDATE: #{my_order.line_items}"
    my_order.line_items = item_array
    my_hash = { "line_items" => item_array }
    body = my_hash.to_json
    # When updating line_items, you need to provide all the data that was in
    # line_items before, otherwise only new parameters will remain! (from Recharge docs)
    recharge_response = HTTParty.put("https://api.rechargeapps.com/orders/#{order_id}",
      :headers => @recharge_change_header,
      :body => body,
      :timeout => 80
    )
    if recharge_response.code == 200
      my_order.save!
      Resque.logger.warn "LINE_ITEMS AFTER UPDATE: #{my_order.line_items}"
      puts "Line_item update Done"
    else
      Resque.logger.error "SOMETHING WENT WRONG#{recharge_response}"
    end
  end

end
