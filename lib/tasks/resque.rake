# frozen_string_literal: true
Dir["#{Rails.root}/app/services/*.rb"].each { |file| require file }
require 'resque/tasks'
# load up rails environment so we have access to
# all models inside of our workers
task 'resque:setup' => :environment

# desc 'Request from API and persist all shopify customer data'
# task :pull_shopify_cust => :environment do
#   ShopifyCustomer.delete_all
#   ActiveRecord::Base.connection.reset_pk_sequence!('shopify_customers')
#   GetDataAPI.save_all_shopify_customers
# end
#
desc 'import redis data'
task 'batch_upsert' => :environment do |t, args|
  Synchronize.perform(*args)
end

desc 'import recharge data [customer || address || subscription || order]'
task 'batch_request' => :environment do |t, args|
  Harvest.perform(*args)
end
