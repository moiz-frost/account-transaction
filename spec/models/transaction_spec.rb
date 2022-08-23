# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id              :bigint           not null, primary key
#  credit_cents    :bigint           default(0), not null
#  credit_currency :string           default("AED"), not null
#  debit_cents     :bigint           default(0), not null
#  debit_currency  :string           default("AED"), not null
#  email           :string
#  first_name      :string
#  last_name       :string
#  phone_number    :string
#  status          :integer          default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_accounts_on_email         (email)
#  index_accounts_on_phone_number  (phone_number)
#  index_accounts_on_status        (status)
#
require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'Validations' do
    before(:each) do
      @account1 = create(:account)
      @account2 = create(:account)
    end

    it 'raises account not verified validation error' do
      expect do
        @account1.deposit!(500)
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Account is not verified')

      expect do
        @account2.deposit!(500)
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Account is not verified')
    end

    it 'raises transaction validation error when an attempt is made to transfer greater than current balance' do
      @account1.verify!
      @account2.verify!

      expect do
        @account1.deposit!(500)
      end.to_not raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Account is not verified')

      expect do
        @account1.transfer!(@account2, 1000)
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Transaction amount should be greater than or equal to current account balance')
    end
  end
end
