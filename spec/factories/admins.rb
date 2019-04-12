FactoryBot.define do
  factory :admin_user, class: User do
    email { Faker::Internet.email }
    password { "Password123!!"}
    password_confirmation { "Password123!!" }
    confirmed_at { Date.today }
    admin { true }
  end
end
