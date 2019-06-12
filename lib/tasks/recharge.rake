Dir["#{Rails.root}/app/services/*.rb"].each { |file| require file }

desc 'import recharge data [customer || address || subscription || order (_full | _partial)]'
task 'request' => :environment do |t, args|
  Resque.enqueue(Harvest, *args)
end
