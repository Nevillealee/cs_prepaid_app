# 

require 'rails_helper'

RSpec.describe DashboardsController, type: :controller do
  describe 'GET /users/sign_in' do
    context 'when admin' do
      login_admin
      it 'signs in' do
        expect(subject.current_user).to_not eq(nil)
      end
    end

    context 'when authenticated user' do
      login_user
      it 'signs in' do
        expect(subject.current_user).to_not eq(nil)
      end
    end
  end

end
