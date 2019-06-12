module CustomerHelper
  def customer_full_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/customer_full.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Customer full_pull params recieved: #{@entity.inspect}"

    puts "Hi there getting all customers"
    puts params.inspect
    #GET /customers/count
    my_header = params['header']
    myuri = params['uri']
    puts "MYURI= #{myuri}"
    customers = HTTParty.get("https://api.rechargeapps.com/customers/count?status=active", :headers => my_header)
    num_customers = customers['count'].to_i
    Resque.logger.debug "We have #{num_customers} ACTIVE customers"

    Customer.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('customers')

    my_conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
    puts "my_conn: #{my_conn}"
    my_insert = "insert into customers (id, shopify_customer_id, email, created_at, updated_at, status, first_name, last_name, has_card_error_in_dunning, number_subscriptions, number_active_subscriptions, first_charge_processed_at ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) ON CONFLICT (id) DO UPDATE SET shopify_customer_id = EXCLUDED.shopify_customer_id, email = EXCLUDED.email, created_at = EXCLUDED.created_at, updated_at = EXCLUDED.updated_at, status = EXCLUDED.status, first_name = EXCLUDED.first_name, last_name = EXCLUDED.last_name, has_card_error_in_dunning = EXCLUDED.has_card_error_in_dunning, number_subscriptions = EXCLUDED.number_subscriptions, number_active_subscriptions = EXCLUDED.number_active_subscriptions, first_charge_processed_at = EXCLUDED.first_charge_processed_at;"
    my_conn.prepare('statement1', "#{my_insert}")

    start = Time.now
    page_size = 250
    num_pages = (num_customers/page_size.to_f).ceil
    1.upto(num_pages) do |page|
      customers = HTTParty.get("https://api.rechargeapps.com/customers?limit=250&page=#{page}&status=active", :headers => my_header)
      my_customers = customers.parsed_response['customers']
      recharge_limit = customers.response["x-recharge-limit"]
      my_customers.each do |mycust|
        #logger.debug
        puts mycust.inspect
        id = mycust['id']
        shopify_customer_id = mycust['shopify_customer_id']
        email = mycust['email']
        created_at = mycust['created_at']
        updated_at = mycust['updated_at']
        first_name = mycust['first_name']
        last_name = mycust['last_name']
        status = mycust['status']
        has_card_error_in_dunning = mycust['has_card_error_in_dunning']
        number_subscriptions = mycust['number_subscriptions']
        number_active_subscriptions = mycust['number_active_subscriptions']
        first_charge_processed_at = mycust['first_charge_processed_at']
        my_conn.exec_prepared('statement1', [id, shopify_customer_id, email, created_at, updated_at, status, first_name, last_name, has_card_error_in_dunning, number_subscriptions, number_active_subscriptions, first_charge_processed_at])
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

  def customer_partial_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/customer_partial.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Customer partial_pull params recieved: #{@entity.inspect}"

    puts "Hi there getting customers from the last 25 minutes"
    puts params.inspect
    my_header = params['header']
    myuri = params['uri']
    puts "MYURI= #{myuri}"

    twenty_five_minutes_ago_str = twenty_five_min
    Resque.logger.debug "Here twenty_five_minutes_ago_str = #{twenty_five_minutes_ago_str}"
    customers_count = HTTParty.get("https://api.rechargeapps.com/customers/count?updated_at_min=\'#{twenty_five_minutes_ago_str}\'", :headers => my_header)
    my_response = customers_count
    num_customers = my_response['count'].to_i
    Resque.logger.debug "We have #{num_customers} customers updated since twenty five minutes ago: #{twenty_five_minutes_ago_str}"


    my_conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
    puts "my_conn: #{my_conn}"

    my_insert = "insert into customers (id, shopify_customer_id, email, created_at, updated_at, status, first_name, last_name, has_card_error_in_dunning, number_subscriptions, number_active_subscriptions, first_charge_processed_at ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) ON CONFLICT (id) DO UPDATE SET shopify_customer_id = EXCLUDED.shopify_customer_id, email = EXCLUDED.email, created_at = EXCLUDED.created_at, updated_at = EXCLUDED.updated_at, status = EXCLUDED.status, first_name = EXCLUDED.first_name, last_name = EXCLUDED.last_name, has_card_error_in_dunning = EXCLUDED.has_card_error_in_dunning, number_subscriptions = EXCLUDED.number_subscriptions, number_active_subscriptions = EXCLUDED.number_active_subscriptions, first_charge_processed_at = EXCLUDED.first_charge_processed_at;"
    my_conn.prepare('statement1', "#{my_insert}")

    start = Time.now
    page_size = 250
    num_pages = (num_customers/page_size.to_f).ceil
    1.upto(num_pages) do |page|
      customers = HTTParty.get("https://api.rechargeapps.com/customers?updated_at_min=\'#{twenty_five_minutes_ago_str}\'&limit=250&page=#{page}", :headers => my_header)
      my_customers = customers.parsed_response['customers']
      recharge_limit = customers.response["x-recharge-limit"]
      my_customers.each do |mycust|
        puts mycust.inspect
        id = mycust['id']
        shopify_customer_id = mycust['shopify_customer_id']
        email = mycust['email']
        created_at = mycust['created_at']
        updated_at = mycust['updated_at']
        first_name = mycust['first_name']
        last_name = mycust['last_name']
        status = mycust['status']
        has_card_error_in_dunning = mycust['has_card_error_in_dunning']
        number_subscriptions = mycust['number_subscriptions']
        number_active_subscriptions = mycust['number_active_subscriptions']
        first_charge_processed_at = mycust['first_charge_processed_at']
        my_conn.exec_prepared('statement1', [id, shopify_customer_id, email, created_at, updated_at, status, first_name, last_name, has_card_error_in_dunning, number_subscriptions, number_active_subscriptions, first_charge_processed_at])
      end
      puts "Done with page #{page}/#{num_pages}"
      current = Time.now
      duration = (current - start).ceil
      puts "Running #{duration} seconds"
      determine_limits(recharge_limit, 0.75)
    end
    my_conn.close
    puts "DONE"
  end
end
