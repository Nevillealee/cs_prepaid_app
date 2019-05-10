class Harvest
  @queue = :batch_request
  def self.perform(arg)
    puts "Harvest worker enqueued"
    Request.new(arg).run
  end
end
