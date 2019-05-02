# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# email confirmation required
admin = User.create!(email: 'dhkim1211@gmail.com', password: 'password', password_confirmation: 'password', admin: true,  first_name: 'Sean', last_name: 'Carter', confirmed_at: Time.now)
