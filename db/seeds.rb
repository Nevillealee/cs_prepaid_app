# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Change email, password, password_confirmation, first_name, and last_name values
admin = User.create!(email: 'test@changeme.com', password: 'notrealpassword', password_confirmation: 'notrealpassword', admin: true,  first_name: 'fake', last_name: 'name', confirmed_at: Time.now )
