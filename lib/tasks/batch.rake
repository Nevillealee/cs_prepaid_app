# frozen_string_literal: true
Dir["#{Rails.root}/app/services/*.rb"].each { |file| require file }

desc 'import redis data'
task 'batch_upsert' => :environment do |t, args|
  Synchronize.perform(*args)
end

desc 'import recharge data [customer || address || subscription || order]'
task 'batch_request' => :environment do |t, args|
  Harvest.perform(*args)
end
