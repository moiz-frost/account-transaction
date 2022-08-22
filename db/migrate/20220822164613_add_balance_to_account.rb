class AddBalanceToAccount < ActiveRecord::Migration[6.0]
  def self.up
    add_monetize :accounts, :balance, null: false, default: 0
  end

  def self.down
    remove_column :accounts, :balance_cents, if_exists: true
    remove_column :accounts, :balance_currency, if_exists: true
  end
end
