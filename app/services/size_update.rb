require Rails.root.join('app', 'helpers','resque_helper.rb')

# Class for  updating Subscription and attached QUEUED Order sizes
# @param arg [Hash] nested hash (prop_params and  line_items) of form data
class SizeUpdate
  include ResqueHelper

  SIZE_PROPERTIES = ['leggings', 'tops', 'sports-jacket', 'sports-bra', 'gloves'].freeze

  def initialize(arg)
    @form_data = arg
    @my_user_id = arg["current_user_id"]
  end

  def run
    stream_pre_update
    Resque.logger = Logger.new("#{Rails.root}/log/order_size_update.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    Resque.logger.info "PARAMS IN ORDERSIZEUPDATE #{@form_data.inspect}"
    recharge_token = @form_data["recharge_token"]
    recharge_change_header = {
      'X-Recharge-Access-Token' => recharge_token,
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    new_line_items = format_params(@form_data)
    order_id = @form_data["order_id"]
    my_order = Order.find(order_id)
    new_sizes = get_param_sizes(@form_data)
    sub_id = new_line_items['subscription_id'].to_i
    sub = Subscription.find(sub_id)

    # Update Subscription in ReCharge api then locally if HTTP 200
    Resque.logger.warn("Property Update params sub_id(#{sub_id}) found in DB? #{sub_id == sub.id}")
    sub.sizes = new_sizes
    sub_litems = {"properties" => sub.properties}.to_json
    res1 = HTTParty.put(
      "https://api.rechargeapps.com/subscriptions/#{sub_id}",
      :headers => recharge_change_header,
      :body => sub_litems,
      :timeout => 80
      )
    Resque.logger.info("SUBSCRIPTION(#{sub_id}) update response: #{res1.parsed_response}")
    if (res1.code == 200)
      sub.save!
      Resque.logger.info "New Subscription sizes: #{sub.sizes}"
    else
      stream_failure
      Resque.logger.error "SUB ##{sub.id} WAS NOT UPDATED IN DB OR RECHARGE!!!"
    end

    # Recharge API now changes json data automatically on all future QUEUED Orders
    # 'in case you have pre-paid subscription, please use this endpoint since it will
    # regenerate json data on all future orders which were not possible until now.'
    my_order.sizes_change(new_sizes, sub_id)
    my_hash = { "line_items" => reformat_oline_items(my_order.line_items) }
    body = my_hash.to_json
    res2 = HTTParty.put(
      "https://api.rechargeapps.com/orders/#{my_order.id}",
      :headers => recharge_change_header,
      :body => body,
      :timeout => 80
     )
    Resque.logger.info "ORDER SIZE UPDATE RESPONSE: #{res2}"
    if (res2.code == 200)
      my_order.save!
      Resque.logger.info("New Order sizes: #{my_order.sizes(sub_id)}")
      puts "Order size update Done"
      stream_complete_update(res2)
    else
      Resque.logger.error "ORDER ##{my_order.id} WAS NOT UPDATED IN DB OR RECHARGE!!!"
      stream_failure(res2)
    end
  end

  private

  # creates hash of sizes from line_item properties
  # @param arg [Hash] form data
  # @return [Hash] {"leggings"=>"?", "sports-bra"=>"?", "tops"=>"?", "sports-bra"=>"?"}
  def get_param_sizes(arg)
    parameters = arg["prop_params"]
    parameters.select{|p| SIZE_PROPERTIES.include? p}
  end

  def stream_pre_update
    ActionCable.server.broadcast "notifications:#{@my_user_id}", {html:
      "<div class='alert alert-primary alert-block text-center'>
          Sending update sizes request to Recharge API....
      </div>"
      }
  end

  def stream_complete_update(response)
      results = response['order']['line_items'][0]['properties'].select do |hash|
        %w{product_collection leggings sports-bra tops sports-jacket}.include? hash['name']
      end

      ActionCable.server.broadcast "notifications:#{@my_user_id}", {html:
    "<div class='alert alert-success alert-block text-center'>
       Order(#{@form_data['order_id']}) changes now reflected in Recharge: <p>#{results}</p>
       *<a href='/customer/orders/#{@form_data['order_id']}'>Order</a> page may require refresh to show updated values
     </div>"
      }
  end

  def stream_failure(res2)
      ActionCable.server.broadcast "notifications:#{@my_user_id}", {html:
    "<div class='alert alert-danger alert-block text-center'>
        Recharge API Error: #{res2["errors"]}
        Please correct error & resubmit Order(#{@form_data['order_id']}) <a href='/customer/orders/#{@form_data['order_id']}'>here</a>
     </div>"
      }
  end
end
