FactoryBot.define do
  factory :customer do
    id { Faker::Number.number(8) }
    email { Faker::Internet.safe_email}
    shopify_customer_id { Faker::Number.number(12)}
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    created_at { Faker::Date.backward(2) }
    updated_at { Faker::Date.backward(1) }
  end
end
