# frozen_string_literal: true

# == Schema Information
#
# Table name: transactions
#
#  id              :bigint           not null, primary key
#  amount_cents    :bigint           default(0), not null
#  amount_currency :string           default("AED"), not null
#  event           :integer          default("transfer"), not null
#  type            :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint
#  receiver_id     :bigint
#  sender_id       :bigint
#
# Indexes
#
#  index_transactions_on_account_id   (account_id)
#  index_transactions_on_receiver_id  (receiver_id)
#  index_transactions_on_sender_id    (sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (receiver_id => accounts.id)
#  fk_rails_...  (sender_id => accounts.id)
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
