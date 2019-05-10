# 

Faker::Config.locale = 'en-US'

FactoryBot.define do
  factory :address do
    id { Faker::Number.number(7) }
    created_at { Faker::Date.backward(2) }
    updated_at { Faker::Date.backward(1) }
    address1 { Faker::Address.street_address }
    address2 { Faker::Address.secondary_address }
    city { Faker::Address.community }
    province { Faker::Address.state  }
    zip { Faker::Address.zip  }
    phone { Faker::PhoneNumber.phone_number }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end
