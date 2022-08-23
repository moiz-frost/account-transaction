class CookieController < ApplicationController
  # skip_before_action :verify_authenticity_token

  def login
    render json: { error: 'Please enter an email or phone number' }, status: :bad_request and return if params[:email].blank? && params[:phone_number].blank?
    
    render json: { error: 'Password is not present' }, status: :bad_request and return if params[:password].blank?

    email = params[:email]
    phone_number = params[:phone_number]
    password = params[:password]

    account = if email.present?
                Account.find_by_email(email).first
              else
                Account.find_by_phone_number(phone_number).first
              end

    if account.present? && account.valid_password?(password)
      session = Session.generate_or_find_existing_session_for(account)

      cookies.signed[:jwt] = { value: Services::JsonWebToken.encode({ tkn: session.token }), httponly: true }
      render json: { success: true }, status: :ok and return
    end

    render json: { error: 'Incorrect username or password' }, status: :unauthorized
  end
end
