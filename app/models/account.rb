# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id               :bigint           not null, primary key
#  balance_cents    :bigint           default(0), not null
#  balance_currency :string           default("AED"), not null
#  email            :string
#  first_name       :string
#  last_name        :string
#  phone_number     :string
#  status           :integer          default("pending"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_accounts_on_email         (email)
#  index_accounts_on_phone_number  (phone_number)
#  index_accounts_on_status        (status)
#
class Account < ApplicationRecord
  extend FormattableCurrency

  validates :first_name, :last_name, :email, :phone_number, presence: true

  validates_uniqueness_of :email, :phone_number

  monetize :balance_cents, numericality: { greater_than_or_equal_to: 0 }
  formats_money :balance, :available_balance

  # counter_culture :category, column_name: :balance_cents

  # has_many :transactions

  STATUSES = {
    unverified: -1,
    pending: 0,
    verified: 1,
  }.freeze

  enum status: STATUSES, _suffix: true

  def verify!
    update!(status: STATUSES[:verified])
  end
end
