require Rails.root.join('app', 'helpers', 'resque_helper.rb')

class OrderSizeUpdate
  extend ResqueHelper
  puts "MADE IT"
  @queue = :order_size_change

  def self.perform(params)
    ActiveRecord::Base.clear_active_connections!
    puts "inside perform"

    recharge_token = params[:recharge_token]
    @recharge_change_header = {
      'X-Recharge-Access-Token' => recharge_token,
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    new_line_items = format_params(params)

    # sub_id = new_line_items['subscription_id'].to_i,
    # sub = Subscription.find(sub_id)
    # Resque.logger.info("params sub_id: #{sub_id} : db matching sub_id #{sub.id}")
    #
    # # Update subscription through ReCharge api
    # sub_litems = {"properties" => sub.properties}.to_json
    # res1 = HTTParty.put("https://api.rechargeapps.com/subscriptions/#{sub_id}", :headers => @recharge_change_header, :body => sub_litems, :timeout => 80)
    # Resque.logger.info(res1.inspect)
    #
    # queued_orders = Order.where("line_items @> ? AND status = ? AND is_prepaid = ?", [{subscription_id: sub_id}].to_json, "QUEUED", 1)
    # Resque.logger.info("QUEUED_ORDERS found in db matching sub_id(#{sub_id}) #{queued_orders.count}")
    # all_clear = true

    # Iterate through queued orders for sub_id argument and update through REcharge api
    # queued_orders.each do |my_order|
    #   my_order.sizes_change(new_sizes, subscription_id)
    #   Resque.logger.info("Order: #{my_order.order_id} sizes are now #{my_order.sizes(subscription_id)}")
    #   my_hash = { "line_items" => reformat_oline_items(my_order.line_items) }
    #   body = my_hash.to_json
    #   Resque.logger.info "my hash: #{body.inspect}"
    #   @res = HTTParty.put("https://api.rechargeapps.com/orders/#{my_order.order_id}", :headers => @recharge_change_header, :body => body, :timeout => 80)
    #   Resque.logger.info @res
    #   my_order.save! if (@res.code == 200)
    #   all_clear = false if (@res.code != 200)
    # end

    # params = {"subscription_id" => subscription_id, "action" => "change_sizes", "details" => new_sizes  }

    # if all_clear
    #   Resque.enqueue(SendEmailToCustomer, params)
    # else
    #   Resque.enqueue(SendEmailToCS, params)
    # end
  end
end
