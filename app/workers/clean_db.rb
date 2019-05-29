class CleanDb
  @queue = :clean_database
  def self.perform
    puts "Database cleaning in progress..."
    Clean.new.run
  end
end
