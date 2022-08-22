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
  end
end
