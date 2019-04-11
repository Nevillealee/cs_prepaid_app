require 'rails_helper'

RSpec.describe 'Dashboards endpoint', type: :request do
  # Test suite for GET /index
  describe 'GET /' do
    # make HTTP get request before each example
    before { get '/' }

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end
end
