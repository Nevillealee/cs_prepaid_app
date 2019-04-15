PRODUCT_COLLECTION ||= "Prism Perfect - 3 Items"
PREPAID_THREE ||= 1635509436467
PREPAID_FIVE ||= 1635509469235
month_start = Time.now.beginning_of_month
month_end = Time.now.end_of_month

FactoryBot.define do
  factory :order  do
    transient do
      sub_id { rand.to_s[2..9].to_i }
    end
    id { rand.to_s[2..9] }
    status { "QUEUED" }
    order_type { 'CHECKOUT' }
    shopify_order_id { rand.to_s[2..13] }
    shopify_order_number { rand.to_s[2..5] }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    is_prepaid { 1 }
    scheduled_at { Faker::Date.unique.between(Date.today + 1, month_end) }
    raw_line_items { [{
      sku: "99999999",
      price: "0.00",
      title: "3 Months 3 items",
      quantity: 1,
      properties: [
          {
              name: "charge_interval_frequency",
              value: "3"
          },
          {
              name: "charge_interval_unit_type",
              value: "Months"
          },
          {
              name: "leggings",
              value: "S"
          },
          {
              name: "main-product",
              value: "true"
          },
          {
              name: "product_collection",
              value: PRODUCT_COLLECTION,
          },
          {
              name: "product_id",
              value: PREPAID_THREE,
          },
          {
              name: "referrer",
              value: ""
          },
          {
              name: "shipping_interval_frequency",
              value: "1"
          },
          {
              name: "shipping_interval_unit_type",
              value: "Months"
          },
          {
              name: "sports-bra",
              value: "S"
          },
          {
              name: "tops",
              value: "S"
          }
      ],
      product_title: "3 Months 3 Items",
      variant_title: "",
      subscription_id: sub_id.to_i,
      shopify_product_id: PREPAID_THREE.to_s,
      shopify_variant_id: rand.to_s[2..14],
    }].to_json }
    created_at { Faker::Date.unique }
    updated_at { Faker::Date.unique }
  end
end
