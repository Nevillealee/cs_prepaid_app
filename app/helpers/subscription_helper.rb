module SubscriptionHelper
  def subscription_full_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/subscription_full.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Subscription full_pull params recieved: #{@entity.inspect}"
  end

  def subscription_partial_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/subscription_partial.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Subscription partial_pull params recieved: #{@entity.inspect}"
  end
end
