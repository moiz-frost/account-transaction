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
class Session < ApplicationRecord
  DEFAULT_EXPIRATION_TIME = 3.days.freeze

  belongs_to :resource, polymorphic: true

  before_validation :set_token_and_expiration, on: :create

  scope :active, -> { where('expires_at > ?', Time.current.utc) }

  class << self
    def authenticate(token)
      Session.where(token: token).where('expires_at > ?', Time.current.utc).first
    end

    def generate_or_find_existing_session_for(resource)
      session = Session.active.find_by(resource: resource)
      if session.present?
        session.update!(expires_at: DEFAULT_EXPIRATION_TIME.from_now)
      else
        session = Session.create!(resource: resource, expires_at: DEFAULT_EXPIRATION_TIME.from_now)
      end
      session
    end
  end

  def expire!
    return if expires_at < Time.current

    update!(expires_at: Time.current)
  end

  private

  def set_token_and_expiration
    self.expires_at ||= DEFAULT_EXPIRATION_TIME.from_now
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Session.exists?(token: random_token)
    end
  end
end
