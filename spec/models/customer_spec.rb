# 

require 'rails_helper'

RSpec.describe Customer, type: :model do
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

  context '#search' do
    before(:each) do
      5.times do
        FactoryBot.create(:customer)
      end
    end
    context 'with params[:q]' do
      let!(:customer) { FactoryBot.create(:customer, first_name: 'Goku', last_name: 'kakorot') }
     context 'when one word entered' do
       it 'returns a collection of customers first_name matching word' do
         params = { q: 'goku' }
         results = Customer.search(params)
         expect(results).to all(have_attributes(first_name: include('Goku')))
      end
     end

     context 'when more than one word entered' do
       it 'returns customers matching words with first name or last name' do
         params = { q: 'GOku lee' }
         results = Customer.search(params)
         expect(results).to all(
           have_attributes(first_name: include('goku')).or have_attributes(last_name: include('lee'))
         )
       end
     end

     context 'when ID number entered' do
       it 'returns customer with matching shopify_customer_id or id' do
         params = { q: '123456789' }
         cust = FactoryBot.create(:customer, id: 123456789)
         results = Customer.search(params)
         expect(results).to all(
           have_attributes(id: 123456789).or have_attributes(shopify_customer_id: 123456789)
         )
       end
     end
     context 'when special characters entered' do
       it 'returns all customers' do
         params = { q: '@$#*$^%*#@(@$()+_-=~``' }
         results = Customer.search(params)
         expect(results).to eq(Customer.order(first_name: :asc))
       end
     end
     context 'when alphanumeric string entered' do
       it 'returns all customers' do
         params = { q: 'abcde fg2384 992' }
         results = Customer.search(params)
         expect(results).to eq(Customer.order(first_name: :asc))
       end
     end
     context 'when string with leading/trailing whitespace entered' do
       it 'returns matching customers within previous rulesets' do
         params = { q: ' goku kak    ' }
         results = Customer.search(params)
         expect(results).to all(
           have_attributes(first_name: include('goku')).or have_attributes(last_name: include('kak'))
         )
       end
     end
    end
    # context 'without params[:q]' do
    # MOVED TO REQUEST SPEC, case handled in controller
    # end
  end
end
