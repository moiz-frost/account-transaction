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
        time: Formatters::DateFormater.format_with_time(@account1.transactions.last.created_at),
      }.as_json)
    end

    it 'fails to transfer money from account1 to account2' do
      post "/api/v1/accounts/#{@account1.id}/transfer", params: { amount: 50_000, email: 'test2@me.com' }

      expect(response).to have_http_status(403)

      expect(JSON.parse(response.body)).to match({
        errors: {
          'test1@me.com': { base: ['Transaction amount should be greater than or equal to current account balance'] },
          'test2@me.com': {},
        },
      }
      .as_json)
    end

    it 'successfully retrieves transactions for account1' do
      get "/api/v1/accounts/#{@account1.id}/transactions"

      expect(response).to have_http_status(200)

      credit_time = Formatters::DateFormater.format_with_time(@account1.transactions.last.created_at)

      expect(JSON.parse(response.body)).to match(
        [
          { amount: 'AED 5,000.00', type: 'credit', event: 'deposit', sender: '', receiver: '', time: credit_time }
        ].as_json
      )

      Timecop.freeze

      post "/api/v1/accounts/#{@account1.id}/transfer", params: { amount: 500, email: 'test2@me.com' }
      post "/api/v1/accounts/#{@account1.id}/transfer", params: { amount: 500, email: 'test2@me.com' }
      post "/api/v1/accounts/#{@account1.id}/transfer", params: { amount: 500, email: 'test2@me.com' }

      transaction_time = Formatters::DateFormater.format_with_time(@account1.transactions.last.created_at)

      Timecop.return

      get "/api/v1/accounts/#{@account1.id}/transactions"

      expect(JSON.parse(response.body)).to match(
        [
          { amount: 'AED 5,000.00', type: 'credit', event: 'deposit', sender: '', receiver: '', time: credit_time },
          { amount: 'AED 500.00', type: 'debit', event: 'transfer', sender: 'test1@me.com', receiver: 'test2@me.com', time: transaction_time },
          { amount: 'AED 500.00', type: 'debit', event: 'transfer', sender: 'test1@me.com', receiver: 'test2@me.com', time: transaction_time },
          { amount: 'AED 500.00', type: 'debit', event: 'transfer', sender: 'test1@me.com', receiver: 'test2@me.com', time: transaction_time }
        ].as_json
      )
    end

    it 'fails to transfer money from account1 is unverified' do
      @account1.update!(status: :unverified)

      post "/api/v1/accounts/#{@account1.id}/transfer", params: { amount: 50_000, email: 'test2@me.com' }

      expect(response).to have_http_status(404)

      expect(JSON.parse(response.body)).to match({ errors: 'Not found' }.as_json)
    end

    it 'fails to transfer money from account1 to account2 when account2 is not verified' do
      @account2.update!(status: :unverified)

      post "/api/v1/accounts/#{@account1.id}/transfer", params: { amount: 500, email: 'test2@me.com' }

      expect(response).to have_http_status(403)

      expect(JSON.parse(response.body)).to match({
        errors: {
          'test1@me.com': {},
          'test2@me.com': { account: ['is not verified'] },
        },
      }
      .as_json)
    end
  end
end
