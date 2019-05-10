# 

require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:customer) { FactoryBot.create :customer }
  let(:address) { FactoryBot.create :address, customer_id: customer.id}
  let(:order) { FactoryBot.create :order, customer_id: customer.id, address_id: address.id }

  def min_max
    my_yesterday = Date.today - 1
    my_yesterday_str = my_yesterday.strftime('%Y-%m-%d')
    my_four_months = Date.today # >> 4
    my_four_months = my_four_months.end_of_month
    my_four_months_str = my_four_months.strftime('%Y-%m-%d')
    my_hash = { min: my_yesterday_str, max: my_four_months_str }
  end

  context 'Requestable module' do
    let(:min) { min_max[:min] }
    let(:max) { min_max[:max] }
    let(:q_params) { { query: "scheduled_at_min=#{min}&scheduled_at_max=#{max}",
                          entity: 'order' } }

    describe '.fetch' do
      it 'caches Recharge Order data in Redis' do
        expect(customer.fetch(q_params)).to eq(true)
      end
    end
  end

end
