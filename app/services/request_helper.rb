module RequestHelper
  def customer_pull(params)
    Resque.logger.info "Harvest.perform params recieved: #{@entity.inspect}"

    puts "Hi there getting all customers"
    puts params.inspect
    #GET /customers/count
    my_header = params['header']
    uri = params['uri']

    customers = HTTParty.get("https://api.rechargeapps.com/customers/count?", :headers => my_header)
    #puts customers.inspect
    num_customers = customers['count'].to_i
    puts "We have #{num_customers} customers"


    Customer.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('customers')
    myuri = URI.parse(uri)
    my_conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
    my_insert = "insert into customers (id, shopify_customer_id, email, created_at, updated_at, status, first_name, last_name, has_card_error_in_dunning, number_subscriptions, number_active_subscriptions, first_charge_processed_at ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) ON CONFLICT (id) DO UPDATE SET shopify_customer_id = EXCLUDED.shopify_customer_id, email = EXCLUDED.email, created_at = EXCLUDED.created_at, updated_at = EXCLUDED.updated_at, status = EXCLUDED.status, first_name = EXCLUDED.first_name, last_name = EXCLUDED.last_name, has_card_error_in_dunning = EXCLUDED.has_card_error_in_dunning, number_subscriptions = EXCLUDED.number_subscriptions, number_active_subscriptions = EXCLUDED.number_active_subscriptions, first_charge_processed_at = EXCLUDED.first_charge_processed_at"
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
      puts "Done with page #{page}"
      current = Time.now
      duration = (current - start).ceil
      puts "Running #{duration} seconds"
      determine_limits(recharge_limit, 0.65)
    end
    my_conn.close
  end
end
