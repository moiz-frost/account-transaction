class RemoveBalanceFromAccount < ActiveRecord::Migration[6.0]
  def change
    remove_column :accounts, :balance_cents, if_exists: true
    remove_column :accounts, :balance_currency, if_exists: true
  end
end
