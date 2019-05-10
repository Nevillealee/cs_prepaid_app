# 
require 'rails_helper'

RSpec.describe Customer::OrdersController, type: :controller do
  describe 'PUT /customer/orders/:id' do
    let(:customer) { FactoryBot.create :customer }
    let(:address) { FactoryBot.create :address, customer_id: customer.id}
    let(:order) { FactoryBot.create :order, customer_id: customer.id, address_id: address.id }

    it { should route(:patch, "/customer/orders/#{order.id}").to(action: :update, id: order.id) }
  end
end
