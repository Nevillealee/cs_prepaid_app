class OrderUpdate
  @queue = :order_line_item_update
  def self.perform(arg)
    puts "Order line_item update update enqueued"
    LineItemUpdate.new(arg).run
  end
end
