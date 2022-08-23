# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                 :bigint           not null, primary key
#  credit_cents       :bigint           default(0), not null
#  credit_currency    :string           default("AED"), not null
#  debit_cents        :bigint           default(0), not null
#  debit_currency     :string           default("AED"), not null
#  email              :string
#  encrypted_password :string           default(""), not null
#  first_name         :string
#  last_name          :string
#  phone_number       :string
#  status             :integer          default("pending"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_accounts_on_email         (email)
#  index_accounts_on_phone_number  (phone_number)
#  index_accounts_on_status        (status)
#
require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'Validations' do
    before(:each) do
      @account = create(:account)
    end

    it 'has a valid factory' do
      expect(@account).to be_valid
    end

    it 'checks presence of values' do
      expect(@account.first_name).to be_present
      expect(@account.last_name).to be_present
      expect(@account.phone_number).to be_present
      expect(@account.email).to be_present
    end

    it 'checks for phone number uniqueness' do
      expect do
        create(:account, phone_number: @account.phone_number)
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Phone number has already been taken')
    end

    it 'checks for email uniqueness' do
      expect do
        create(:account, email: @account.email)
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Email has already been taken')
    end
  end

  describe 'Account balance' do
    before(:each) do
      @account1 = create(:account, status: :verified)
      @account2 = create(:account, status: :verified)
    end

    it 'correctly updates account balance on each deposit and withdrawal' do
      expect(@account1.balance).to eq 0

      @account1.deposit!(500)

      expect(@account1.reload.balance).to eq Money.new(50_000)
      expect(@account1.transactions.last.amount).to eq Money.new(50_000)
      expect(@account1.transactions.last.type).to eq 'credit'
      expect(@account1.transactions.last.event).to eq 'deposit'
      expect(@account1.transactions.last.sender).to be_nil
      expect(@account1.transactions.last.receiver).to be_nil

      @account1.withdraw!(50)

      expect(@account1.reload.balance).to eq Money.new(45_000)
      expect(@account1.transactions.last.amount).to eq Money.new(5000)
      expect(@account1.transactions.last.type).to eq 'debit'
      expect(@account1.transactions.last.event).to eq 'withdrawal'
      expect(@account1.transactions.last.sender).to be_nil
      expect(@account1.transactions.last.receiver).to be_nil
    end

    it 'correctly updates account balance on each account transfer' do
      @account1.deposit!(500)

      @account1.transfer!(@account2, 100)

      expect(@account1.reload.balance).to eq Money.new(40_000)
      expect(@account1.transactions.last.amount).to eq Money.new(10_000)
      expect(@account1.transactions.last.type).to eq 'debit'
      expect(@account1.transactions.last.event).to eq 'transfer'
      expect(@account1.transactions.last.sender).to eq @account1
      expect(@account1.transactions.last.receiver).to eq @account2

      expect(@account2.reload.balance).to eq Money.new(10_000)
      expect(@account2.transactions.last.amount).to eq Money.new(10_000)
      expect(@account2.transactions.last.type).to eq 'credit'
      expect(@account2.transactions.last.event).to eq 'transfer'
      expect(@account2.transactions.last.sender).to eq @account1
      expect(@account2.transactions.last.receiver).to eq @account2
    end
  end
end
