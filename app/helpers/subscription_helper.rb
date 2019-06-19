module SubscriptionHelper
  def subscription_full_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/subscription_full.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Subscription full_pull params recieved: #{params.inspect}"
    puts "Hi there getting all susbcriptions"
    puts params.inspect

    my_header = params['header']
    myuri = params['uri']
    puts "MYURI= #{myuri}"
    subscriptions = HTTParty.get("https://api.rechargeapps.com/subscriptions/count?status=active", :headers => my_header)
    num_subscriptions = subscriptions['count'].to_i
    Resque.logger.info "We have #{num_subscriptions} ACTIVE subscriptions"

    Subscription.destroy_all

    my_conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
    puts "my_conn: #{my_conn}"
    my_insert = "insert into subscriptions (id, address_id, customer_id, created_at, updated_at, next_charge_scheduled_at, cancelled_at, product_title, variant_title, price, quantity, status, shopify_variant_id, shopify_product_id, recharge_product_id, sku, sku_override, order_interval_unit, order_interval_frequency, charge_interval_frequency, order_day_of_month, order_day_of_week, properties, expire_after_specific_number_of_charges, cancellation_reason, cancellation_reason_comments, max_retries_reached, has_queued_charges) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28) ON CONFLICT (id) DO UPDATE SET address_id = EXCLUDED.address_id, product_title = EXCLUDED.product_title, variant_title = EXCLUDED.variant_title, price = EXCLUDED.price, quantity = EXCLUDED.quantity, shopify_variant_id = EXCLUDED.shopify_variant_id, shopify_product_id = EXCLUDED.shopify_product_id, recharge_product_id = EXCLUDED.recharge_product_id, sku = EXCLUDED.sku, sku_override = EXCLUDED.sku_override, order_interval_unit = EXCLUDED.order_interval_unit, order_interval_frequency = EXCLUDED.order_interval_frequency, charge_interval_frequency = EXCLUDED.charge_interval_frequency, order_day_of_week = EXCLUDED.order_day_of_week, order_day_of_month = EXCLUDED.order_day_of_month, expire_after_specific_number_of_charges = EXCLUDED.expire_after_specific_number_of_charges,
    properties = EXCLUDED.properties, next_charge_scheduled_at = EXCLUDED.next_charge_scheduled_at, cancelled_at = EXCLUDED.cancelled_at, status = EXCLUDED.status, updated_at = EXCLUDED>updated_at;"
    my_conn.prepare('statement1', "#{my_insert}")

    start = Time.now
    page_size = 250
    num_pages = (num_subscriptions/page_size.to_f).ceil
    1.upto(num_pages) do |page|
      subscriptions = HTTParty.get("https://api.rechargeapps.com/subscriptions?limit=250&page=#{page}&status=active", :headers => my_header)
      my_subscriptions = subscriptions.parsed_response['subscriptions']
      recharge_limit = subscriptions.response["x-recharge-limit"]
      my_subscriptions.each do |mysub|
        puts mysub.inspect
        id = mysub['id']
        address_id = mysub['address_id']
        customer_id = mysub['customer_id']
        created_at = mysub['created_at']
        updated_at = mysub['updated_at']
        next_charge_scheduled_at = mysub['next_charge_scheduled_at']
        cancelled_at = mysub['cancelled_at']
        product_title = mysub['product_title']
        variant_title = mysub['variant_title']
        price = mysub['price']
        quantity = mysub['quantity']
        status = mysub['status']
        shopify_variant_id = mysub['shopify_variant_id']
        shopify_product_id = mysub['shopify_product_id']
        recharge_product_id = mysub['recharge_product_id']
        sku = mysub['sku']
        sku_override = mysub['sku_override']
        order_interval_unit = mysub['order_interval_unit']
        order_interval_frequency = mysub['order_interval_frequency']
        charge_interval_frequency = mysub['charge_interval_frequency']
        order_day_of_month = mysub['order_day_of_month']
        order_day_of_week = mysub['order_day_of_week']
        properties = mysub['properties'].to_json
        expire_after_specific_number_of_charges = mysub['expire_after_specific_number_of_charges']
        cancellation_reason = mysub['cancellation_reason']
        cancellation_reason_comments = mysub['cancellation_reason_comments']
        max_retries_reached = mysub['max_retries_reached']
        has_queued_charges = mysub['has_queued_charges']

        my_conn.exec_prepared('statement1', [id, address_id, customer_id, created_at, updated_at, next_charge_scheduled_at, cancelled_at, product_title, variant_title, price, quantity, status, shopify_variant_id, shopify_product_id, recharge_product_id, sku, sku_override, order_interval_unit, order_interval_frequency, charge_interval_frequency, order_day_of_month, order_day_of_week, properties, expire_after_specific_number_of_charges, cancellation_reason, cancellation_reason_comments, max_retries_reached, has_queued_charges])
      end
      puts "Done with page #{page}/#{num_pages}"
      current = Time.now
      duration = (current - start).ceil
      puts "Running #{duration} seconds"
      determine_limits(recharge_limit, 0.65)
    end
    my_conn.close
    puts "DONE"
  end

  def subscription_partial_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/subscription_partial.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Subscription partial_pull params recieved: #{params.inspect}"

    my_header = params['header']
    myuri = params['uri']
    puts "MYURI= #{myuri}"

    twenty_five_minutes_ago_str = twenty_five_min
    Resque.logger.info "Here twenty_five_minutes_ago_str = #{twenty_five_minutes_ago_str}"
    subscriptions_count = HTTParty.get("https://api.rechargeapps.com/subscriptions/count?updated_at_min=\'#{twenty_five_minutes_ago_str}\'&status=active", :headers => my_header)
    my_response = subscriptions_count
    num_subscriptions = my_response['count'].to_i
    Resque.logger.info "We have #{num_subscriptions} Subscriptions updated since twenty five minutes ago: #{twenty_five_minutes_ago_str}"

    my_conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
    puts "my_conn: #{my_conn}"
    my_insert = "insert into subscriptions (id, address_id, customer_id, created_at, updated_at, next_charge_scheduled_at, cancelled_at, product_title, variant_title, price, quantity, status, shopify_variant_id, shopify_product_id, recharge_product_id, sku, sku_override, order_interval_unit, order_interval_frequency, charge_interval_frequency, order_day_of_month, order_day_of_week, properties, expire_after_specific_number_of_charges, cancellation_reason, cancellation_reason_comments, max_retries_reached, has_queued_charges) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28) ON CONFLICT (id) DO UPDATE SET address_id = EXCLUDED.address_id, product_title = EXCLUDED.product_title, variant_title = EXCLUDED.variant_title, price = EXCLUDED.price, quantity = EXCLUDED.quantity, shopify_variant_id = EXCLUDED.shopify_variant_id, shopify_product_id = EXCLUDED.shopify_product_id, recharge_product_id = EXCLUDED.recharge_product_id, sku = EXCLUDED.sku, sku_override = EXCLUDED.sku_override, order_interval_unit = EXCLUDED.order_interval_unit, order_interval_frequency = EXCLUDED.order_interval_frequency, charge_interval_frequency = EXCLUDED.charge_interval_frequency, order_day_of_week = EXCLUDED.order_day_of_week, order_day_of_month = EXCLUDED.order_day_of_month, expire_after_specific_number_of_charges = EXCLUDED.expire_after_specific_number_of_charges,
    properties = EXCLUDED.properties, next_charge_scheduled_at = EXCLUDED.next_charge_scheduled_at, cancelled_at = EXCLUDED.cancelled_at, status = EXCLUDED.status, updated_at = EXCLUDED>updated_at;"
    my_conn.prepare('statement1', "#{my_insert}")

    start = Time.now
    page_size = 250
    num_pages = (num_subscriptions/page_size.to_f).ceil
    1.upto(num_pages) do |page|
      subscriptions = HTTParty.get("https://api.rechargeapps.com/subscriptions?limit=250&page=#{page}&updated_at_min=\'#{twenty_five_minutes_ago_str}\'&status=active", :headers => my_header)
      my_subscriptions = subscriptions.parsed_response['subscriptions']
      recharge_limit = subscriptions.response["x-recharge-limit"]
      my_subscriptions.each do |mysub|
        puts mysub.inspect
        id = mysub['id']
        address_id = mysub['address_id']
        customer_id = mysub['customer_id']
        created_at = mysub['created_at']
        updated_at = mysub['updated_at']
        next_charge_scheduled_at = mysub['next_charge_scheduled_at']
        cancelled_at = mysub['cancelled_at']
        product_title = mysub['product_title']
        variant_title = mysub['variant_title']
        price = mysub['price']
        quantity = mysub['quantity']
        status = mysub['status']
        shopify_variant_id = mysub['shopify_variant_id']
        shopify_product_id = mysub['shopify_product_id']
        recharge_product_id = mysub['recharge_product_id']
        sku = mysub['sku']
        sku_override = mysub['sku_override']
        order_interval_unit = mysub['order_interval_unit']
        order_interval_frequency = mysub['order_interval_frequency']
        charge_interval_frequency = mysub['charge_interval_frequency']
        order_day_of_month = mysub['order_day_of_month']
        order_day_of_week = mysub['order_day_of_week']
        properties = mysub['properties'].to_json
        expire_after_specific_number_of_charges = mysub['expire_after_specific_number_of_charges']
        cancellation_reason = mysub['cancellation_reason']
        cancellation_reason_comments = mysub['cancellation_reason_comments']
        max_retries_reached = mysub['max_retries_reached']
        has_queued_charges = mysub['has_queued_charges']

        my_conn.exec_prepared('statement1', [id, address_id, customer_id, created_at, updated_at, next_charge_scheduled_at, cancelled_at, product_title, variant_title, price, quantity, status, shopify_variant_id, shopify_product_id, recharge_product_id, sku, sku_override, order_interval_unit, order_interval_frequency, charge_interval_frequency, order_day_of_month, order_day_of_week, properties, expire_after_specific_number_of_charges, cancellation_reason, cancellation_reason_comments, max_retries_reached, has_queued_charges])
      end
      puts "Done with page #{page}/#{num_pages}"
      current = Time.now
      duration = (current - start).ceil
      puts "Running #{duration} seconds"
      determine_limits(recharge_limit, 0.65)
    end
    my_conn.close
    puts "DONE"
  end
end
