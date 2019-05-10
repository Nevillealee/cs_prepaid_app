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
task 'batch_sync' => :environment do
  Resque.enqueue(Harvest, 'customer')
  Resque.enqueue(Harvest, 'address')
  Resque.enqueue(Harvest, 'subscription')
  Resque.enqueue(Harvest, 'order')

  Resque.enqueue(Synchronize, 'customer')
  Resque.enqueue(Synchronize, 'address')
  Resque.enqueue(Synchronize, 'subscription')
  Resque.enqueue(Synchronize, 'order')
end
