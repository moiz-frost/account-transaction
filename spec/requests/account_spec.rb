require 'rails_helper'

RSpec.describe 'Accounts', type: :request do
  context 'transfer' do
    before do
      @account1 = create(:account, email: 'test1@me.com', phone_number: '+971562798160', password: '123456', status: 'verified')
      @account2 = create(:account, email: 'test2@me.com', phone_number: '+971562798161', password: '123456', status: 'verified')

      @session1 = create(:session, resource: @account1)
      @account1.deposit!(5000)
    end

    it 'successfully transfers money from account1 to account2' do
      post "/api/v1/accounts/#{@account1.id}/transfer", params: { amount: 500, email: 'test2@me.com' }

      expect(response).to have_http_status(201)

      expect(JSON.parse(response.body)).to match({
        amount: 'AED 500.00',
        type: 'debit',
        event: 'transfer',
        sender: @account1.email,
        receiver: @account2.email,
      }.as_json)
    end

    it 'fails to transfer money from account1 to account2' do
      post "/api/v1/accounts/#{@account1.id}/transfer", params: { amount: 50_000, email: 'test2@me.com' }

      expect(response).to have_http_status(403)

      expect(JSON.parse(response.body)).to match({
        errors: {
          base: ['Transaction amount should be greater than or equal to current account balance'],
        },
      }.as_json)
    end

    it 'successfully retrieves transactions for account1' do
      get "/api/v1/accounts/#{@account1.id}/transactions"

      expect(response).to have_http_status(200)

      expect(JSON.parse(response.body)).to match(
        [
          { amount: 'AED 5,000.00', type: 'credit', event: 'deposit', sender: '', receiver: '' }
        ].as_json
      )

      post "/api/v1/accounts/#{@account1.id}/transfer", params: { amount: 500, email: 'test2@me.com' }
      post "/api/v1/accounts/#{@account1.id}/transfer", params: { amount: 500, email: 'test2@me.com' }
      post "/api/v1/accounts/#{@account1.id}/transfer", params: { amount: 500, email: 'test2@me.com' }

      get "/api/v1/accounts/#{@account1.id}/transactions"

      expect(JSON.parse(response.body)).to match(
        [
          { amount: 'AED 5,000.00', type: 'credit', event: 'deposit', sender: '', receiver: '' },
          { amount: 'AED 500.00', type: 'debit', event: 'transfer', sender: 'test1@me.com', receiver: 'test2@me.com' },
          { amount: 'AED 500.00', type: 'debit', event: 'transfer', sender: 'test1@me.com', receiver: 'test2@me.com' },
          { amount: 'AED 500.00', type: 'debit', event: 'transfer', sender: 'test1@me.com', receiver: 'test2@me.com' }
        ].as_json
      )
    end
  end
end
