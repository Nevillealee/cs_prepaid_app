require 'rails_helper'

RSpec.describe Order, type: :model do
  describe '.api_count' do
    let(:customer) { FactoryBot.create :customer }
    let(:address) { FactoryBot.create :address, customer_id: customer.id}
    let(:order) { FactoryBot.create :order, customer_id: customer.id, address_id: address.id }
    it 'returns an integer' do
      @recharge_token = ENV['RECHARGE_STAGING_TOKEN']
      params = {
        'X-Recharge-Access-Token' => @recharge_token,
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
      }
      expect(order.api_count(params)).to be_an(Integer)
    end
  end
end
