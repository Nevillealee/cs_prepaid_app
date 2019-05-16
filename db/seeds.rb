#

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# email confirmation required
admin = User.create!(email: 'CHANGEME@FAKE.com', password: 'CHANGEMETOO', password_confirmation: 'CHANGEMETHREE', admin: true,  first_name: 'IIII', last_name: 'ReadInstructions', confirmed_at: Time.now )
