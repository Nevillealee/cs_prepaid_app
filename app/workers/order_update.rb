class OrderUpdate
  @queue = :recharge
  def self.perform(arg)
    puts "Order line_item update update enqueued"
    LineItemUpdate.new(arg).run
  end
end
