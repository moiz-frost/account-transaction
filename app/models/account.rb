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
class Account < ApplicationRecord
  devise :database_authenticatable

  include FormattableCurrency

  STATUSES = {
    unverified: -1,
    pending: 0,
    verified: 1,
  }.freeze

  validates_presence_of :first_name, :last_name, :email, :phone_number

  validates_uniqueness_of :email, :phone_number

  monetize :credit_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :debit_cents, numericality: { greater_than_or_equal_to: 0 }

  # formats balance like "AED 501.5"
  formats_money :balance

  has_many :transactions

  enum status: STATUSES, _suffix: true

  STATUSES.each do |key, _|
    scope key, -> { where(status: key) }
  end

  scope :find_by_email, ->(email) { where(email: email) }
  scope :find_by_phone_number, ->(phone_number) { where(phone_number: phone_number) }

  before_validation :set_default_password, on: :create, if: ->(i) { i.encrypted_password.blank? }

  def withdraw!(amount = 0)
    transactions.create!(
      amount: amount,
      type: Transaction::TYPES[:debit],
      event: Transaction::EVENTS[:withdrawal]
    )
  end

  def deposit!(amount = 0)
    transactions.create!(
      amount: amount,
      type: Transaction::TYPES[:credit],
      event: Transaction::EVENTS[:deposit]
    )
  end

  def transfer(destination_account, amount)
    # acquire an exclusive lock before updating
    with_lock do
      transaction = transactions.create(
        amount: amount,
        type: Transaction::TYPES[:debit],
        event: Transaction::EVENTS[:transfer],
        sender: self,
        receiver: destination_account
      )

      destination_account_transaction = destination_account.transactions.create(
        amount: amount,
        type: Transaction::TYPES[:credit],
        event: Transaction::EVENTS[:transfer],
        sender: self,
        receiver: destination_account
      )

      [transaction, destination_account_transaction]
    end
  end

  def transfer!(destination_account, amount)
    # acquire an exclusive lock before updating
    with_lock do
      transaction = transactions.create!(
        amount: amount,
        type: Transaction::TYPES[:debit],
        event: Transaction::EVENTS[:transfer],
        sender: self,
        receiver: destination_account
      )

      destination_account.transactions.create!(
        amount: amount,
        type: Transaction::TYPES[:credit],
        event: Transaction::EVENTS[:transfer],
        sender: self,
        receiver: destination_account
      )

      transaction
    end
  end

  def verify!
    update!(status: STATUSES[:verified])
  end

  # we keep credit and debit amounts separately so that we can return the correct balance in one shot
  # we dont store it separately because balance is determined from the ledger which in our case are transactions
  def balance
    credit - debit
  end

  private

  def set_default_password
    self.encrypted_password = SecureRandom.uuid
  end
end
