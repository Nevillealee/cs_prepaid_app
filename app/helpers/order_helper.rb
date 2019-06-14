module OrderHelper
  def order_full_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/order_full.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Order full_pull params recieved: #{@entity.inspect}"

    puts "Hi there getting all orders"
    puts "params recieved: #{params}"
    my_header = params['header']
    myuri = params['uri']
    puts "MYURI= #{myuri}"
    date_range = min_max
    min = date_range['min']
    max = date_range['max']

    orders = HTTParty.get("https://api.rechargeapps.com/orders/count?scheduled_at_min=#{min}&scheduled_at_max=#{max}&status=queued", :headers => my_header)
    num_orders = orders['count'].to_i
    Resque.logger.info "We have #{num_orders} orders"

    Order.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('order_line_items')

    my_conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
    puts "my_conn: #{my_conn}"
    my_insert = "insert into orders (id, customer_id, address_id, charge_id, transaction_id, shopify_order_id, shopify_order_number,
      processed_at, status, first_name, last_name, email, payment_processor, scheduled_at,
      is_prepaid, line_items, shipping_address, total_price, billing_address, created_at, updated_at)
      values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21) ON CONFLICT (id) DO UPDATE SET customer_id = EXCLUDED.customer_id, charge_id = EXCLUDED.charge_id,
      transaction_id = EXCLUDED.transaction_id, shopify_order_id = EXCLUDED.shopify_order_id, shopify_order_number = EXCLUDED.shopify_order_number,
      processed_at = EXCLUDED.processed_at, status = EXCLUDED.status, first_name = EXCLUDED.first_name, last_name = EXCLUDED.last_name, email = EXCLUDED.email, payment_processor = EXCLUDED.payment_processor,
      is_prepaid = EXCLUDED.is_prepaid, total_price = EXCLUDED.total_price, created_at = EXCLUDED.created_at;"
    my_conn.prepare('statement1', "#{my_insert}")

    order_line_insert = "insert into order_line_items (order_id, subscription_id, grams, price,
    quantity, shopify_product_id, shopify_variant_id, properties, product_title,  sku, variant_title,
    created_at, updated_at) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13);"
    my_conn.prepare('statement2', "#{order_line_insert}")

    start = Time.now
    page_size = 250
    num_pages = (num_orders/page_size.to_f).ceil
    1.upto(num_pages) do |page|
      orders = HTTParty.get("https://api.rechargeapps.com/orders?limit=250&page=#{page}&scheduled_at_min=#{min}&scheduled_at_max=#{max}&status=queued", :headers => my_header)
      my_orders = orders.parsed_response['orders']
      recharge_limit = orders.response["x-recharge-limit"]

      my_orders.each do |my_order|
        puts my_order.inspect
        id = my_order['id']
        customer_id = my_order['customer_id']
        address_id = my_order['address_id']
        charge_id = my_order['charge_id']
        transaction_id = my_order['transaction_id']
        shopify_order_id = my_order['shopify_order_id']
        shopify_order_number = my_order['shopify_order_number']
        processed_at = my_order['processed_at']
        status = my_order['status']
        first_name = my_order['first_name']
        last_name = my_order['last_name']
        email = my_order['email']
        payment_processor = my_order['payment_processor']
        scheduled_at = my_order['scheduled_at']
        is_prepaid = my_order['is_prepaid']
        shipping_address = my_order['shipping_address'].to_json
        total_price = my_order['total_price']
        billing_address = my_order['billing_address'].to_json
        created_at = my_order['created_at']
        updated_at = my_order['updated_at']
        line_items = my_order['line_items'].to_json

        raw_line_items = my_order['line_items'][0]
        subscription_id = raw_line_items['subscription_id'].to_i
        grams = raw_line_items['grams'].to_i
        price = raw_line_items['price']
        quantity = raw_line_items['quantity']
        properties = raw_line_items['properties'].to_json
        product_title = raw_line_items['product_title']
        shopify_product_id = raw_line_items['shopify_product_id'].to_i
        shopify_variant_id = raw_line_items['shopify_variant_id'].to_i
        sku = raw_line_items['sku']
        variant_title = raw_line_items['variant_title']

        my_delete = "delete from order_line_items where order_id = \'#{id}\'"
        my_conn.exec(my_delete)
        my_conn.exec_prepared(
          'statement1', [id, customer_id, address_id, charge_id, transaction_id,
          shopify_order_id, shopify_order_number, processed_at, status, first_name, last_name, email,
          payment_processor, scheduled_at, is_prepaid, line_items, shipping_address, total_price,
          billing_address, created_at, updated_at]
        )

        my_conn.exec_prepared(
          'statement2', [id, subscription_id, grams, price, quantity, shopify_product_id,
            shopify_variant_id, properties, product_title, sku, variant_title, created_at, updated_at]
          )
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

  def order_partial_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/order_partial.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Order partial_pull params recieved: #{@entity.inspect}"
    puts "Hi there getting all orders"
    puts "params recieved: #{params}"
    my_header = params['header']
    myuri = params['uri']
    puts "MYURI= #{myuri}"

    twenty_five_minutes_ago_str = twenty_five_min
    Resque.logger.info "Here twenty_five_minutes_ago_str = #{twenty_five_minutes_ago_str}"
    orders_count = HTTParty.get("https://api.rechargeapps.com/orders/count?updated_at_min=\'#{twenty_five_minutes_ago_str}\'&status=queued", :headers => my_header)
    my_response = orders_count
    num_orders = my_response['count'].to_i
    Resque.logger.info "We have #{num_orders} orders updated since twenty five minutes ago: #{twenty_five_minutes_ago_str}"

    Order.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('orders')

    my_conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
    puts "my_conn: #{my_conn}"
    my_insert = "insert into orders (id, customer_id, address_id, charge_id, transaction_id, shopify_order_id, shopify_order_number,
      processed_at, status, first_name, last_name, email, payment_processor, scheduled_at,
      is_prepaid, line_items, shipping_address, total_price, billing_address, created_at, updated_at)
      values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21) ON CONFLICT (id) DO UPDATE SET customer_id = EXCLUDED.customer_id, charge_id = EXCLUDED.charge_id,
      transaction_id = EXCLUDED.transaction_id, shopify_order_id = EXCLUDED.shopify_order_id, shopify_order_number = EXCLUDED.shopify_order_number,
      processed_at = EXCLUDED.processed_at, status = EXCLUDED.status, first_name = EXCLUDED.first_name, last_name = EXCLUDED.last_name, email = EXCLUDED.email, payment_processor = EXCLUDED.payment_processor,
      is_prepaid = EXCLUDED.is_prepaid, total_price = EXCLUDED.total_price, created_at = EXCLUDED.created_at;"
    my_conn.prepare('statement1', "#{my_insert}")

    start = Time.now
    page_size = 250
    num_pages = (num_orders/page_size.to_f).ceil
    1.upto(num_pages) do |page|
      orders = HTTParty.get("https://api.rechargeapps.com/orders?limit=250&page=#{page}&updated_at_min=\'#{twenty_five_minutes_ago_str}\'&status=queued", :headers => my_header)
      my_orders = orders.parsed_response['orders']
      recharge_limit = orders.response["x-recharge-limit"]

      my_orders.each do |my_order|
        puts my_order.inspect
        id = my_order['id']
        customer_id = my_order['customer_id']
        address_id = my_order['address_id']
        charge_id = my_order['charge_id']
        transaction_id = my_order['transaction_id']
        shopify_order_id = my_order['shopify_order_id']
        shopify_order_number = my_order['shopify_order_number']
        processed_at = my_order['processed_at']
        status = my_order['status']
        first_name = my_order['first_name']
        last_name = my_order['last_name']
        email = my_order['email']
        payment_processor = my_order['payment_processor']
        scheduled_at = my_order['scheduled_at']
        is_prepaid = my_order['is_prepaid']
        line_items = my_order['line_items'].to_json
        shipping_address = my_order['shipping_address'].to_json
        total_price = my_order['total_price']
        billing_address = my_order['billing_address'].to_json
        created_at = my_order['created_at']
        updated_at = my_order['updated_at']

        my_conn.exec_prepared(
          'statement1', [id, customer_id, address_id, charge_id, transaction_id,
          shopify_order_id, shopify_order_number, processed_at, status, first_name, last_name, email,
          payment_processor, scheduled_at, is_prepaid, line_items, shipping_address, total_price,
          billing_address, created_at, updated_at]
        )
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

  def min_max
    my_yesterday = Date.today - 1
    my_yesterday_str = my_yesterday.strftime('%Y-%m-%d')
    my_four_months = Date.today >> 4
    my_four_months = my_four_months.end_of_month
    my_four_months_str = my_four_months.strftime('%Y-%m-%d')
    my_hash = { min: my_yesterday_str, max: my_four_months_str }
  end
end
