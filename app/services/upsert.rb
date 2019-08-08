require Rails.root.join('app', 'helpers','requestable.rb')

# synchronizes Redis with Active record
class Upsert
  include Requestable
  Resque.logger = Logger.new("#{Rails.root}/log/batch_upsert.log", 5, 10024000)
  Resque.logger.level = Logger::INFO
  def initialize(arg)
    @entity = arg
  end

  def run
    Resque.logger.info "Synchronize.perform params recieved: #{@entity.inspect}"
    @key = "#{@entity}_pull:#{Time.now.strftime("%Y%m%d")}"
    my_class = @entity.camelize.constantize
    parent_hash = hash_get_all(@key)
    temp = []
    my_columns = import_columns(@entity)

    Resque.logger.info "Redis hkey used: #{@key}"
    Resque.logger.info "parent_hash in Synchronize.perform nil?: #{parent_hash.nil?}"

    # converts parent_hash from Hash with {'redis hset field' keys => 'recharge json responses'} into
    # array of ruby Hashes representing individual Recharge objects (orders, customers, etc..)
    parent_hash.try(:each) { |val| temp << JSON.parse(val[1])["#{@entity.pluralize}"] }
    # my_hashes = temp.flatten
    Resque.logger.info "#{@entity} batches in redis before import: #{temp.size}"
    # active-import columns to save
    temp.try(:each) do |my_hashes|
      # Rails (db user given in env or config) must have superuser privilleges
      ActiveRecord::Base.connection.disable_referential_integrity do
        #TODO(Neville lee) replace [:all] with my_columns.map!(&:to_sym)
        my_class.import(my_columns, my_hashes, batch_size: 10000, on_duplicate_key_update: :all)
      end
    end
    Resque.logger.info "#{@entity}s now in DB: #{my_class.count(:all)}"
  end

  private

  # creates an array of table columns for active import
  #
  # @param ent [String] the model's columns needed
  # @return [Array<String>] the corresponding table's fields
  def import_columns(ent)
    case ent
    when 'order'
       %w{ id customer_id address_id charge_id transaction_id shopify_order_id shopify_order_number
           processed_at status first_name last_name email payment_processor scheduled_at
           is_prepaid line_items shipping_address total_price billing_address created_at
           updated_at
         }
    when 'customer'
       %w{ id shopify_customer_id email created_at updated_at status first_name last_name
           has_card_error_in_dunning number_subscriptions number_active_subscriptions
           first_charge_processed_at
         }
    when 'address'
       Address.column_names
    when 'subscription'
       Subscription.column_names
    when 'order_line_item'
       OrderLineItem.column_names
    else
      Resque.logger.warn "rake task argument: #{@entity} is invalid!!!"
    end
  end
end
