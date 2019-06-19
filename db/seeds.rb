# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# email confirmation required
admin = User.create!(email: ENV['SEED_EMAIL'], password: ENV['SEED_PW'], password_confirmation: ENV['SEED_PW'], admin: true,  first_name: 'Test', last_name: 'Admin', confirmed_at: Time.now )
