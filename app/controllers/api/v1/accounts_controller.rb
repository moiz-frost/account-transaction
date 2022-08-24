module Api
  module V1
    class AccountsController < BaseController
      before_action :set_account

      # POST /account/transfer
      def transfer
        transactions = @account.transfer(receiver_account, transfer_params[:amount])
        if transactions.first.save && transactions.second.save
          render json: transactions.first, status: :created
        else
          errors = {}
          errors[account_email_or_phone_number] = transactions.first.errors.messages
          errors[receiver_email_or_phone_number] = transactions.second.errors.messages

          render json: {
            errors: errors,
          }, status: :forbidden
        end
      end

      # GET /account/transactions
      def transactions
        transactions = @account.transactions.includes(:sender, :receiver).order(:created_at)
        render json: transactions
      end

      private

      def set_account
        @account = Account.verified.find(params[:id])
      end

      def account_email_or_phone_number
        email = @account.email
        phone_number = @account.phone_number

        email || phone_number
      end

      def receiver_email_or_phone_number
        email = transfer_params[:email]
        phone_number = transfer_params[:phone_number]

        email || phone_number
      end

      def receiver_account
        email = transfer_params[:email]
        phone_number = transfer_params[:phone_number]

        if email.present?
          Account.find_by_email(email).first
        else
          Account.find_by_phone_number(phone_number).first
        end
      end

      def transfer_params
        params.permit(:email, :phone, :amount)
      end
    end
  end
end
