
task "resque:setup" => :environment do
  ENV['QUEUE'] ||= '*'
  puts "The current environment is: #{Rails.env}"
end
