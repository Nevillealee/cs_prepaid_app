Dir["#{Rails.root}/app/services/*.rb"].each { |file| require file }

desc 'upsert redis cache [customer || address || subscription || order]'
task 'batch_upsert' => :environment do |t, args|
  Resque.enqueue(Synchronize, *args)
end

desc 'import recharge data [customer || address || subscription || order]'
task 'batch_request' => :environment do |t, args|
  Resque.enqueue(Harvest, *args)
end

desc 'pull and upsert all data'
task 'batch_mass_request' => :environment do
  Resque.enqueue(Harvest, 'customer')
  Resque.enqueue(Harvest, 'address')
  Resque.enqueue(Harvest, 'subscription')
  Resque.enqueue(Harvest, 'order')
end

desc 'upsert all data'
task 'batch_mass_upsert' => :environment do
  Resque.enqueue(Synchronize, 'customer')
  Resque.enqueue(Synchronize, 'address')
  Resque.enqueue(Synchronize, 'subscription')
  Resque.enqueue(Synchronize, 'order')
end

# removes cancelled Orders and Subscriptions from db
desc 'remove invalid Orders from db'
task 'clean_database' => :environment do
  Resque.enqueue(CleanDb)
end
