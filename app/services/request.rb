require Rails.root.join('app', 'helpers','requestable.rb')

# caches Recharge batch data in Redis
class Request
  include Requestable
  Resque.logger = Logger.new("#{Rails.root}/log/batch_request.log", 5, 10024000)
  Resque.logger.level = Logger::INFO

  def initialize(arg)
    @entity = arg
  end

  def run
    Resque.logger.info "Harvest.perform params recieved: #{@entity.inspect}"
    my_class = @entity.camelize.constantize
    my_min_max = min_max
    params = query_params(@entity, my_min_max)
    my_class.new.fetch(params)
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
