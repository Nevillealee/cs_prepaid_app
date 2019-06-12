Dir["#{Rails.root}/app/helpers/*.rb"].each { |file| require file }

class Request
  include RechargeLimiting
  include TwentyFive
  include CustomerHelper
  include AddressHelper
  include OrderHelper
  include SubscriptionHelper

  Resque.logger = Logger.new("#{Rails.root}/log/request_worker.log", 5, 10024000)
  Resque.logger.level = Logger::INFO

  def initialize(arg)
    @entity = arg
    recharge_regular = ENV['RECHARGE_TOKEN']
    @sleep_recharge = ENV['RECHARGE_SLEEP_TIME']
    @my_header = {
      "X-Recharge-Access-Token" => recharge_regular
    }
    @uri = URI.parse(ENV['DATABASE_URL'])
    @my_params = {'header' => @my_header, 'uri' => @uri, 'sleep' => @sleep_recharge, 'entity' => @entity}
  end

  def run
    case @entity
    when 'customer_full'
      customer_full_pull(@my_params)
    when 'customer_partial'
      customer_partial_pull(@my_params)

    when 'subscription_full'
      subscription_full_pull(@my_params)
    when 'subscription_partial'
      subscription_partial_pull(@my_params)

    when 'address_full'
      address_full_pull(@my_params)
    when 'address_partial'
      address_partial_pull(@my_params)

    when 'order_full'
      order_full_pull(@my_params)
    when 'order_partial'
      order_partial_pull(@my_params)
    else
      Resque.logger "Invalid argument: #{@entity}"
    end
  end


  # def query_params(ent, minn_maxx)
  #   min = minn_maxx[:min]
  #   max = minn_maxx[:max]
  #   case ent
  #   when 'customer'
  #     { query: 'status=active', entity: ent }
  #   when 'order'
  #     Resque.logger.warn "Order query min: #{min}, max: #{max}"
  #     { query: "scheduled_at_min=#{min}&scheduled_at_max=#{max}&status=queued", entity: ent }
  #   when 'address'
  #     { query: "created_at_max=#{Date.today.strftime('%Y-%m-%d')}", entity: ent}
  #   when 'subscription'
  #     { query: 'status=active', entity: ent }
  #   when 'order_line_item'
  #   else
  #     Resque.logger.warn "rake task argument: #{ent} is invalid!!!"
  #   end
  # end



end
