# 

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'Password123!!'}
    password_confirmation { 'Password123!!' }
    confirmed_at { Date.today }
  end
end
