module AddressHelper
  def address_full_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/address_full.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Address full_pull params recieved: #{@entity.inspect}"
  end

  def address_partial_pull(params)
    Resque.logger = Logger.new("#{Rails.root}/log/address_partial.log", 5, 10024000)
    Resque.logger.level = Logger::INFO
    puts "Address partial_pull params recieved: #{@entity.inspect}"
  end
end
