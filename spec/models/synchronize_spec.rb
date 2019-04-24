# frozen_string_literal: true

require Rails.root.join('app', 'helpers','requestable.rb')
require 'rails_helper'

RSpec.describe Synchronize, type: :model do
  describe "active-import" do
    it "retrieves redis json" do
      param = { entity: 'customer' }
      params = {
         :url => ENV['TEST_DATABASE_URL'],
         :adapter => "postgresql"
     }
     # ActiveRecord::Base.should_receive(:establish_connection).with(params)
     #  Synchronize.perform(param)
    end
  end
end
