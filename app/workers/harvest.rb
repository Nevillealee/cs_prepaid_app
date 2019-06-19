class Harvest
  @queue = :harvest
  def self.perform(arg)
    puts "Harvest worker enqueued"
    Request.new(arg).run
  end
end
