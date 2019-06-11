class CustomersFullBackground
  extend FullBackgroundCustomers
  @queue = "customers_full_background"
  def self.perform(params)
    get_background_full_customers(params)
  end

# # class get_background_full_customers
#   def initialize
#     recharge_regular = ENV['RECHARGE_ACCESS_TOKEN']
#     @sleep_recharge = ENV['RECHARGE_SLEEP_TIME']
#     @my_header = {
#       "X-Recharge-Access-Token" => recharge_regular
#     }
#
#     @uri = URI.parse(ENV['DATABASE_URL'])
#     #@conn = PG.connect(@uri.hostname, @uri.port, nil, nil, @uri.path[1..-1], @uri.user, @uri.password)
#   end

  #background_full_customers.rb

require_relative '../lib/recharge_limit'
require 'active_support/core_ext/time'

module FullBackgroundCustomers
    include ReChargeLimits

    def get_background_full_customers(params)
        puts "Hi there getting all customers"
        puts params.inspect
        #GET /customers/count
        my_header = params['headers']
        uri = params['uri']


        customers = HTTParty.get("https://api.rechargeapps.com/customers/count?", :headers => my_header)
        #puts customers.inspect
        num_customers = customers['count'].to_i
        puts "We have #{num_customers} customers"


        Customer.delete_all
        ActiveRecord::Base.connection.reset_pk_sequence!('customers')
        myuri = URI.parse(uri)
        my_conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
        #my_insert = "insert into customers (customer_id, customer_hash, shopify_customer_id, email, created_at, updated_at, first_name, last_name, billing_address1, billing_address2, billing_zip, billing_city, billing_company, billing_province, billing_country, billing_phone, processor_type, status) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)"
        my_insert = "insert into customers (customer_id, customer_hash, shopify_customer_id, email, created_at, updated_at, first_name, last_name, billing_address1, billing_address2, billing_zip, billing_city, billing_company, billing_province, billing_country, billing_phone, processor_type, status) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18) ON CONFLICT (customer_id) DO UPDATE SET customer_hash = EXCLUDED.customer_hash, shopify_customer_id = EXCLUDED.shopify_customer_id, email = EXCLUDED.email, created_at = EXCLUDED.created_at, updated_at = EXCLUDED.updated_at, first_name = EXCLUDED.first_name, last_name = EXCLUDED.last_name, billing_address1 = EXCLUDED.billing_address1, billing_address2 = EXCLUDED.billing_address2, billing_zip = EXCLUDED.billing_zip, billing_city = EXCLUDED.billing_city, billing_company = EXCLUDED.billing_company, billing_province = EXCLUDED.billing_province, billing_country = EXCLUDED.billing_country, billing_phone = EXCLUDED.billing_phone, processor_type = EXCLUDED.processor_type, status = EXCLUDED.status"
        my_conn.prepare('statement1', "#{my_insert}")

        start = Time.now
        page_size = 250
        num_pages = (num_customers/page_size.to_f).ceil
        1.upto(num_pages) do |page|
            customers = HTTParty.get("https://api.rechargeapps.com/customers?limit=250&page=#{page}", :headers => my_header)
          my_customers = customers.parsed_response['customers']
          recharge_limit = customers.response["x-recharge-limit"]
          my_customers.each do |mycust|
            #logger.debug
            puts mycust.inspect
            customer_id = mycust['id']
            hash = mycust['hash']
            shopify_customer_id = mycust['shopify_customer_id']
            email = mycust['email']
            created_at = mycust['created_at']
            updated_at = mycust['updated_at']
            first_name = mycust['first_name']
            last_name = mycust['last_name']
            billing_address1 = mycust['billing_address1']
            billing_address2 = mycust['billing_address2']
            billing_zip = mycust['billing_zip']
            billing_city = mycust['billing_city']
            billing_company = mycust['billing_company']
            billing_province = mycust['billing_province']
            billing_country = mycust['billing_country']
            billing_phone = mycust['billing_phone']
            processor_type = mycust['processor_type']
            status = mycust['status']
            my_conn.exec_prepared('statement1', [customer_id, hash, shopify_customer_id, email, created_at, updated_at, first_name, last_name, billing_address1, billing_address2, billing_zip, billing_city, billing_company, billing_province, billing_country, billing_phone, processor_type, status])
          end
          puts "Done with page #{page}"
          current = Time.now
          duration = (current - start).ceil
          puts "Running #{duration} seconds"
          determine_limits(recharge_limit, 0.65)

        end
        #do pages

        my_conn.close

    end



  end
