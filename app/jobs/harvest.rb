# synchronizes Recharge with Redis
require Rails.root.join('app', 'helpers','requestable.rb')
require Rails.root.join('app', 'models','customer.rb')
require 'dotenv/load'
require 'active_support'

class Harvest < ActiveRecord::Base
  Resque.logger = Logger.new(STDOUT)
  extend Requestable

  def self.perform(arg)
    Resque.logger.debug "Harvest.perform params recieved: #{arg.inspect}"
    @entity = arg
    my_class = @entity.camelize.constantize
    my_min_max = min_max
    params = query_params(@entity, my_min_max)
    my_class
    my_class.new.fetch(params)
  end

  def self.min_max
    my_yesterday = Date.today - 1
    my_yesterday_str = my_yesterday.strftime('%Y-%m-%d')
    my_four_months = Date.today >> 4
    my_four_months = my_four_months.end_of_month
    my_four_months_str = my_four_months.strftime('%Y-%m-%d')
    my_hash = { min: my_yesterday_str, max: my_four_months_str }
  end

  def self.query_params(ent, minn_maxx)
    min = minn_maxx[:min]
    max = minn_maxx[:max]
    case ent
    when 'customer'
      { query: 'status=active', entity: ent }
    when 'order'
      { query: 'scheduled_at_min=2018-01-01', entity: ent } #CS needs order history for customer inquiry
      # { query: "scheduled_at_min=#{min}&scheduled_at_max=#{max}", entity: ent }
    when 'address'
      { query: "created_at_max=#{Date.today.strftime('%Y-%m-%d')}", entity: ent}
    when 'subscription'
      { query: 'status=active', entity: ent }
    when 'order_line_item'
    else
      Resque.logger "rake task argument: #{ent} is invalid!!!"
    end
  end

end
