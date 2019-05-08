require 'resque/tasks'

task "resque:setup" => :environment do
  puts "The current environment is: #{Rails.env}"
end
