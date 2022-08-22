# == Schema Information
#
# Table name: transactions
#
#  id              :bigint           not null, primary key
#  amount_cents    :bigint           default(0), not null
#  amount_currency :string           default("AED"), not null
#  type            :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint
#
# Indexes
#
#  index_transactions_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Transaction < ApplicationRecord
  self.inheritance_column = :_type_disabled

  include FormattableCurrency

  TYPES = {
    debit: 0,
    credit: 1,
  }.freeze

  default_scope { includes(:account) }

  belongs_to :account

  validates_presence_of :account, :type

  validate :account_status
  validate :account_balance

  monetize :amount_cents, numericality: { greater_than_or_equal_to: 0 }
  formats_money :amount

  counter_culture :account, column_name: proc { |model| model.credit_type? ? :credit_cents : nil }, delta_column: :amount_cents
  counter_culture :account, column_name: proc { |model| model.debit_type? ? :debit_cents : nil }, delta_column: :amount_cents

  enum type: TYPES, _suffix: true

  private

  def account_status
    return if account.verified_status?

    errors.add(:account, 'is not verified')
  end

  def account_balance
    return unless debit_type?

    account_balance = account.balance
    errors.add(:amount, 'should be greater than or equal to current account balance') if (account_balance - amount).negative?
  end
end
