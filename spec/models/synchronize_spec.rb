# frozen_string_literal: true

require Rails.root.join('app', 'helpers','requestable.rb')
require 'rails_helper'

RSpec.describe Synchronize, type: :model do
  context 'Subscriptions' do
    describe '.batch_upsert' do
      it 'saves responses in redis cache' do
        Harvest.perform('subscription')
        params = { query: 'status=active', entity: 'subscription'}
        api_count = Subscription.new.api_count(params)
        Synchronize.perform('subscription')
        row_count = Subscription.count(:all)
        expect(row_count).to eq(api_count)
      end
    end
  end

  context 'Orders' do
    describe '.batch_upsert' do
      it 'saves responses in redis cache', focus: true do
        Harvest.perform('order')
        my_four_months = Date.today >> 4
        my_four_months = my_four_months.end_of_month
        max = my_four_months.strftime('%Y-%m-%d')
        min = (Date.today - 1).strftime('%Y-%m-%d')

        params = { query: 'scheduled_at_min=2018-01-01', entity: 'order'}
        api_count = Order.new.api_count(params)
        Synchronize.perform('order')
        row_count = Order.count(:all)
        expect(row_count).to eq(api_count)
      end
    end
  end
end
