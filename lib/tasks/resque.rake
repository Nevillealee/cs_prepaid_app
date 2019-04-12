# loads custom tasks provided in resque gem
Dir["#{Rails.root}/app/services/*.rb"].each { |file| require file }
require "resque/tasks"
# load up rails environment so we have access to
# all models inside of our workers
task "resque:setup" => :environment

# desc 'Request from API and persist all shopify customer data'
# task :pull_shopify_cust => :environment do
#   ShopifyCustomer.delete_all
#   ActiveRecord::Base.connection.reset_pk_sequence!('shopify_customers')
#   GetDataAPI.save_all_shopify_customers
# end
#
# desc 'remove prospect tag from active subscribers'
# task :remove_prospect => :environment do
#   GetDataAPI.remove_prospect
# end
