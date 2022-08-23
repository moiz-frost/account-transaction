# == Schema Information
#
# Table name: sessions
#
#  id            :bigint           not null, primary key
#  expires_at    :datetime         not null
#  resource_type :string           not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resource_id   :bigint           not null
#
# Indexes
#
#  index_sessions_on_resource_type_and_resource_id  (resource_type,resource_id)
#  index_sessions_on_token                          (token) UNIQUE
#
FactoryBot.define do
  factory :session do
    association :resource, factory: :account
  end
end
