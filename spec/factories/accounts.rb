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
FactoryBot.define do
  factory :account do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
    status { Account.statuses[:unverified] }
    password { '123456' }
  end
end
