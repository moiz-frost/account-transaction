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
require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'Validations and callbacks' do
    before(:each) do
      Timecop.freeze
      @session = create(:session)
    end

    after do
      Timecop.return
    end

    it 'should set token and expiration date' do
      @session.validate
      expect(@session.expires_at.utc).to eq(Session::DEFAULT_EXPIRATION_TIME.from_now.utc)
      expect(@session.token).to be_truthy
    end
  end

  describe 'Authentication' do
    before do
      @session = create(:session)
      Time.freeze
    end

    after do
      Timecop.return
    end

    it 'should return session if token is valid and not expired' do
      expect(Session.authenticate(@session.token).id).to eq(@session.id)
      expect(Session.authenticate('fake')).to be_nil

      Timecop.travel(2.months.from_now)
      expect(Session.authenticate(@session.token)).to be_nil
    end
  end

  describe 'Expiration' do
    before do
      @session = create(:session)
      Time.freeze
    end

    after do
      Timecop.return
    end

    it 'should return session if token is valid and not expired' do
      expect(Session.authenticate(@session.token).id).to eq(@session.id)
      expect(Session.authenticate('fake')).to be_nil

      @session.expire!
      expect(Session.authenticate(@session.token)).to be_nil
    end
  end

  describe 'generate_or_find_existing_session_for' do
    before do
      @account = create(:account)
      @session = create(:session, resource: @account)
    end

    it 'should return the same session if it exists token is valid and not expired' do
      expect(Session.count).to be 1

      expect(Session.generate_or_find_existing_session_for(@account)).to eq @session
      @session.expire!

      expect(Session.generate_or_find_existing_session_for(@account)).to_not eq @session
      expect(Session.count).to be 2
    end
  end
end
