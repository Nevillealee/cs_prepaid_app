# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  let(:customer) { FactoryBot.create :customer }

  def min_max
    my_yesterday = Date.today - 1
    my_yesterday_str = my_yesterday.strftime('%Y-%m-%d')
    my_four_months = Date.today >> 4
    my_four_months = my_four_months.end_of_month
    my_four_months_str = my_four_months.strftime('%Y-%m-%d')
    my_hash = { min: my_yesterday_str, max: my_four_months_str }
  end

  context 'Requestable module' do
    let(:min) { min_max[:min] }
    let(:max) { min_max[:max] }
    let(:q_params) { { query: "updated_at_min=#{min}&updated_at_max=#{max}",
                       entity: 'customer' } }

     describe '.fetch' do
       it 'batch requests ReCharge customers' do
         expect(customer.fetch(q_params)).to eq(true)
       end
     end
   end


end
