class Synchronize
  # batch upserts redis hashes into database
  # @params arg [String] command line model name argument from rake task
  @queue = :batch_upsert
  puts "Synchronize worker enqueued"
  def self.perform(arg)
    Upsert.new(arg).run
  end
end
