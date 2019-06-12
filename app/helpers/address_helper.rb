module AddressHelper
  def address_full_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/address_full.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Address full_pull params recieved: #{@entity.inspect}"
    puts "Hi there getting all addresses"
    puts "params recieved: #{params}"
    my_header = params['header']
    myuri = params['uri']
    puts "MYURI= #{myuri}"
    addresses = HTTParty.get("https://api.rechargeapps.com/addresses/count", :headers => my_header)
    num_addresses = addresses['count'].to_i
    Resque.logger.info "We have #{num_addresses} addresses"

    Address.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('addresses')

    my_conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
    puts "my_conn: #{my_conn}"
    my_insert = "insert into addresses (id, customer_id, created_at, updated_at, address1, address2, city, province, country, first_name, last_name, zip, company, phone, cart_note, note_attributes, shipping_lines_override, discount_id ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18) ON CONFLICT (id) DO UPDATE SET customer_id = EXCLUDED.customer_id, created_at = EXCLUDED.created_at, updated_at = EXCLUDED.updated_at, address1 = EXCLUDED.address1, address2 = EXCLUDED.address2, city = EXCLUDED.city, province = EXCLUDED.province, country = EXCLUDED.country, first_name = EXCLUDED.first_name, last_name = EXCLUDED.last_name, zip = EXCLUDED.zip, company = EXCLUDED.company, phone = EXCLUDED.phone, cart_note = EXCLUDED.cart_note, note_attributes = EXCLUDED.note_attributes, shipping_lines_override = EXCLUDED.shipping_lines_override, discount_id = EXCLUDED.discount_id;"
    my_conn.prepare('statement1', "#{my_insert}")

    start = Time.now
    page_size = 250
    num_pages = (num_addresses/page_size.to_f).ceil
    1.upto(num_pages) do |page|
      addresses = HTTParty.get("https://api.rechargeapps.com/addresses?limit=250&page=#{page}", :headers => my_header)
      my_addresses = addresses.parsed_response['addresses']
      recharge_limit = addresses.response["x-recharge-limit"]
      my_addresses.each do |my_add|
        puts my_add.inspect
        id = my_add['id']
        customer_id = my_add['customer_id']
        created_at = my_add['created_at']
        updated_at = my_add['updated_at']
        address1 = my_add['address1']
        address2 = my_add['address2']
        city = my_add['city']
        province = my_add['province']
        country = my_add['country']
        first_name = my_add['first_name']
        last_name = my_add['last_name']
        zip = my_add['zip']
        company = my_add['company']
        phone = my_add['phone']
        cart_note = my_add['cart_note']
        note_attributes = my_add['note_attributes'].to_json
        shipping_lines_override = my_add['shipping_lines_override'].to_json
        discount_id = my_add['discount_id']
        my_conn.exec_prepared('statement1', [id, customer_id, created_at, updated_at, address1, address2, city, province, country, first_name, last_name, zip, company, phone, cart_note, note_attributes, shipping_lines_override, discount_id])
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

  def address_partial_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/address_partial.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Address partial_pull params recieved: #{@entity.inspect}"
    puts "Hi there getting addresses from the last 25 minutes"
    puts "params recieved: #{params}"
    my_header = params['header']
    myuri = params['uri']
    puts "MYURI= #{myuri}"

    twenty_five_minutes_ago_str = twenty_five_min
    Resque.logger.info "Here twenty_five_minutes_ago_str = #{twenty_five_minutes_ago_str}"
    addresses_count = HTTParty.get("https://api.rechargeapps.com/addresses/count?updated_at_min=\'#{twenty_five_minutes_ago_str}\'", :headers => my_header)
    my_response = addresses_count
    num_addresses = my_response['count'].to_i
    Resque.logger.info "We have #{num_addresses} addresses updated since twenty five minutes ago: #{twenty_five_minutes_ago_str}"

    my_conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
    puts "my_conn: #{my_conn}"
    my_insert = "insert into addresses (id, customer_id, created_at, updated_at, address1, address2, city, province, country, first_name, last_name, zip, company, phone, cart_note, note_attributes, shipping_lines_override, discount_id ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18) ON CONFLICT (id) DO UPDATE SET customer_id = EXCLUDED.customer_id, created_at = EXCLUDED.created_at, updated_at = EXCLUDED.updated_at, address1 = EXCLUDED.address1, address2 = EXCLUDED.address2, city = EXCLUDED.city, province = EXCLUDED.province, country = EXCLUDED.country, first_name = EXCLUDED.first_name, last_name = EXCLUDED.last_name, zip = EXCLUDED.zip, company = EXCLUDED.company, phone = EXCLUDED.phone, cart_note = EXCLUDED.cart_note, note_attributes = EXCLUDED.note_attributes, shipping_lines_override = EXCLUDED.shipping_lines_override, discount_id = EXCLUDED.discount_id;"
    my_conn.prepare('statement1', "#{my_insert}")

    start = Time.now
    page_size = 250
    num_pages = (num_addresses/page_size.to_f).ceil
    1.upto(num_pages) do |page|
      addresses = HTTParty.get("https://api.rechargeapps.com/addresses?updated_at_min=\'#{twenty_five_minutes_ago_str}\'&limit=250&page=#{page}", :headers => my_header)
      my_addresses = addresses.parsed_response['addresses']
      recharge_limit = addresses.response["x-recharge-limit"]
      my_addresses.each do |my_add|
        puts my_add.inspect
        id = my_add['id']
        customer_id = my_add['customer_id']
        created_at = my_add['created_at']
        updated_at = my_add['updated_at']
        address1 = my_add['address1']
        address2 = my_add['address2']
        city = my_add['city']
        province = my_add['province']
        country = my_add['country']
        first_name = my_add['first_name']
        last_name = my_add['last_name']
        zip = my_add['zip']
        company = my_add['company']
        phone = my_add['phone']
        cart_note = my_add['cart_note']
        note_attributes = my_add['note_attributes'].to_json
        shipping_lines_override = my_add['shipping_lines_override'].to_json
        discount_id = my_add['discount_id']
        my_conn.exec_prepared('statement1', [id, customer_id, created_at, updated_at, address1, address2, city, province, country, first_name, last_name, zip, company, phone, cart_note, note_attributes, shipping_lines_override, discount_id])
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
