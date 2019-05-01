# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Orders", type: :request do
  describe 'request order property update' do
    before do
      ResqueSpec.reset!
    end
    let(:customer) { FactoryBot.create :customer }
    let(:address) { FactoryBot.create :address, customer_id: customer.id}
    let(:order) { FactoryBot.create :order, customer_id: customer.id, address_id: address.id }
    #
    # it 'enqueues OrderUpdate job' do
    #   query = { order: { customer_id: customer.id, id: order.id, billing_address: '5553 Bandini blvd' } }
    #   put '/customer/orders/:id', params: query
    #   expect(response).to be_successful
    #   expect(response).to render_template(:show)
    #   expect(OrderUpdate).to have_queued(params).in(:order)
    # end
  end
end
