module Api
  module V1
    class AccountsController < BaseController
      before_action :set_account

      # POST /account/transfer
      def transfer
        transaction = @account.transfer(receiver_account, transfer_params[:amount])
        if transaction.save
          render json: transaction, status: :created
        else
          render json: { errors: transaction.errors }, status: :forbidden
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

      # assumption is that receiver account will always exist
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
