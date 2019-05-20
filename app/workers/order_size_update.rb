class OrderSizeUpdate
  @queue = :recharge
  def self.perform(arg)
    puts "Order size update enqueued"
    SizeUpdate.new(arg).run
  end
end
