# frozen_string_literal: true

class Api::V1::BaseController < ::ApplicationController
  before_action :authenticate_account!

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  protected

  def authenticate_account!; end
end
