Resque.redis = $redis
Resque.logger.level = Logger::INFO
Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))
