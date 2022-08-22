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
class Account < ApplicationRecord
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

  formats_money :balance

  has_many :transactions

  enum status: STATUSES, _suffix: true

  def verify!
    update!(status: STATUSES[:verified])
  end

  # we keep credit and debit amounts separately so that we can return the correct balance in one shot
  def balance
    credit - debit
  end
end
