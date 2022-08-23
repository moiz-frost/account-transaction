require 'rails_helper'

RSpec.describe CookieController, type: :controller do
  describe 'login' do
    before do
      @account = create(:account, email: 'test@me.com', phone_number: '+971562798160', password: '123456')
    end

    it 'should login account user in system with email and password' do
      expect(Session.count).to eq 0

      post :login, params: { email: 'test@me.com', password: '123456' }
      data = JSON.parse(response.body)['success']
      expect(data).to eq(true)
      expect(cookies.signed[:jwt]).not_to be_nil

      expect(Session.count).to eq 1

      post :login, params: { phone_number: '+971562798160', password: '123456' }
      data = JSON.parse(response.body)['success']
      expect(data).to eq(true)
      expect(cookies.signed[:jwt]).not_to be_nil

      expect(Session.count).to eq 1
    end

    it 'should not login account user in the system with incorrect email' do
      expect(Session.count).to eq 0

      post :login, params: { email: 'tesst@me.com', password: '123456' }
      error = JSON.parse(response.body)['error']
      expect(error).to eq('Incorrect username or password')
      expect(response).to have_http_status(:unauthorized)
      expect(cookies.signed[:jwt]).to be_nil

      expect(Session.count).to eq 0
    end

    it 'should not login user in system with invalid params' do
      post :login, params: {}
      error = JSON.parse(response.body)['error']
      expect(error).to eq('Please enter an email or phone number')
      expect(response).to have_http_status(:bad_request)
      expect(cookies.signed[:jwt]).to be_nil

      post :login, params: { email: 'test123@me.co' }
      error = JSON.parse(response.body)['error']
      expect(error).to eq('Password is not present')
      expect(response).to have_http_status(:bad_request)
      expect(cookies.signed[:jwt]).to be_nil
    end
  end
end
