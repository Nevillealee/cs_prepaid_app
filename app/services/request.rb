require Rails.root.join('app', 'helpers','requestable.rb')

# caches Recharge batch data in Redis
class Request
  include RequestHelper
  Resque.logger = Logger.new("#{Rails.root}/log/batch_request.log", 5, 10024000)
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
    when 'customer'
      customer_pull(@my_params)
    when 'subscription'
      subscription_pull(@my_params)
    when 'address'
      address_pull(@my_params)
    when 'order'
      order_pull(@my_params)
    else
      Resque.logger "Invalid argument: #{@entity}"
    end
  end

  private

  def query_params(ent, minn_maxx)
    min = minn_maxx[:min]
    max = minn_maxx[:max]
    case ent
    when 'customer'
      { query: 'status=active', entity: ent }
    when 'order'
      Resque.logger.warn "Order query min: #{min}, max: #{max}"
      { query: "scheduled_at_min=#{min}&scheduled_at_max=#{max}&status=queued", entity: ent }
    when 'address'
      { query: "created_at_max=#{Date.today.strftime('%Y-%m-%d')}", entity: ent}
    when 'subscription'
      { query: 'status=active', entity: ent }
    when 'order_line_item'
    else
      Resque.logger.warn "rake task argument: #{ent} is invalid!!!"
    end
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
