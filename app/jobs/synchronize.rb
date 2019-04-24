# synchronizes Redis with Active record
require Rails.root.join('app', 'helpers','requestable.rb')
require Rails.root.join('app', 'models','customer.rb')
require 'dotenv/load'
require 'active_support'

class Synchronize < ActiveRecord::Base
  Resque.logger = Logger.new(STDOUT)
  extend Requestable

  def self.perform(arg)
    Resque.logger.debug "Synchronize.perform params recieved: #{arg.inspect}"
    @entity = arg
    @key = "#{@entity}_pull:#{Time.now.strftime("%Y%m%d")}"
    my_class = @entity.camelize.constantize
    parent_hash = hash_get_all(@key)
    temp = []
    my_columns = import_columns(@entity)

    Resque.logger.debug "Redis hkey used: #{@key}"
    Resque.logger.debug "parent_hash in Synchronize.perform nil?: #{parent_hash.nil?}"
    # converts parent_hash from Hash with {'redis hset field' keys => 'recharge json responses'} into
    # array of ruby Hashes representing individual Recharge objects (orders, customers, etc..)
    parent_hash.try(:each) { |val| temp << JSON.parse(val[1])["#{@entity}s"] }
    my_hashes = temp.flatten
    Resque.logger.debug "#{@entity}s in redis before import: #{my_hashes.size}"
    # active-import columns to save
    ActiveRecord::Base.connection.disable_referential_integrity do
      results = my_class.import(my_columns,
                                my_hashes,
                                batch_size: 10000,
                                returning: :id,
                                on_duplicate_key_update: :all
                              )
      puts "inserts: #{results.num_inserts}"
      # puts "Successful #{@entity}_ids: #{results.results}"
      puts "#{@entity}s now in DB: #{my_class.count(:all)}"
      puts "fails: #{results.failed_instances}"
    end
  end

  # columns auto_generated, if external api changes keys, write out columns to import explicitly
  def self.import_columns(ent)
    case ent
    when 'order'
      return %w{ id customer_id address_id charge_id transaction_id shopify_order_id shopify_order_number
                 processed_at status first_name last_name email payment_processor scheduled_at
                 is_prepaid line_items shipping_address total_price billing_address created_at
                 updated_at }
    when 'customer'
      return %w{ id shopify_customer_id email created_at updated_at status first_name last_name
                 has_card_error_in_dunning number_subscriptions number_active_subscriptions
                 first_charge_processed_at }
    when 'address'
      return Address.column_names
    when 'subscription'
      return Subscription.column_names
    when 'order_line_item'
      return OrderLineItem.column_names
    else
      Resque.logger "rake task argument: #{@entity} is invalid!!!"
    end
  end


end
