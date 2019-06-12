module OrderHelper
  def order_full_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/order_full.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Order full_pull params recieved: #{@entity.inspect}"
  end

  def order_partial_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/order_partial.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Order partial_pull params recieved: #{@entity.inspect}"
  end
end
