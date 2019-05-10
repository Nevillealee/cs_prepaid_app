class OrderSizeUpdate
  @queue = :order_size_update
  def self.perform(arg)
    puts "Order size update enqueued"
    SizeUpdate.new(arg).run
  end
end
