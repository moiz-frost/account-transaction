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
class Transaction < ApplicationRecord
  # transaction is a reserved word
  self.inheritance_column = :_type_disabled

  include FormattableCurrency

  EVENTS = {
    transfer: 0,
    deposit: 1,
    withdrawal: 2,
  }.freeze

  TYPES = {
    debit: 0,
    credit: 1,
  }.freeze

  default_scope { includes(:account) }

  belongs_to :account
  belongs_to :sender, class_name: 'Account', optional: true
  belongs_to :receiver, class_name: 'Account', optional: true

  validates_presence_of :account, :type

  validate :account_balance
  validate :sender_receiver
  validate :account_verification

  monetize :amount_cents, numericality: { greater_than_or_equal_to: 0 }
  formats_money :amount

  # cache counter ensures credits and debits are up to date all the time
  counter_culture :account, column_name: proc { |model| model.credit_type? ? :credit_cents : nil }, delta_column: :amount_cents
  counter_culture :account, column_name: proc { |model| model.debit_type? ? :debit_cents : nil }, delta_column: :amount_cents

  enum type: TYPES, _suffix: true
  enum event: EVENTS, _suffix: true

  private

  def account_balance
    return unless debit_type?

    account_balance = account.balance
    errors.add(:base, 'Transaction amount should be greater than or equal to current account balance') if (account_balance - amount).negative?
  end

  def sender_receiver
    return if sender.blank? && receiver.blank?

    if sender.blank?
      errors.add(:sender, 'is not present')
    elsif receiver.blank?
      errors.add(:receiver, 'is not present')
    end

    errors.add(:base, 'Sender cannot be the receiver') if sender == receiver
  end

  def account_verification
    return if account.verified_status?

    errors.add(:account, 'is not verified')
  end
end
