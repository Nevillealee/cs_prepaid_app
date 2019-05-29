# caches Recharge batch data in Redis
class Clean
  Resque.logger = Logger.new("#{Rails.root}/log/clean_database.log", 5, 10024000)
  Resque.logger.level = Logger::INFO
  
  def run
    Resque.logger.info "Clean.run started"
    invalid_orders = Order.where("scheduled_at < ?", Date.today - 1 )
    Resque.logger.info "#{invalid_orders.size} Orders to delete"

    invalid_orders.each do |ord|
      Resque.logger.warn "DELETED ORDER(#{ord.id}) from database, was scheduled_at: #{ord.scheduled_at}"
      ord.destroy
    end
    new_total = Order.where("scheduled_at < ?", Date.today - 1 ).count
    Resque.logger.info "#{new_total} invalid Orders now in database"
  end
end
