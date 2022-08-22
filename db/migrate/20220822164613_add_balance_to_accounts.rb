class AddBalanceToAccounts < ActiveRecord::Migration[6.0]
  def self.up
    add_monetize :accounts, :balance, null: false, default: 0
  end

  def self.down
    remove_column :accounts, :balance_cents
    remove_column :accounts, :balance_amount
  end
end
