class AddCreditAndDebitToAccount < ActiveRecord::Migration[6.0]
  def self.up
    add_monetize :accounts, :credit, null: false, default: 0
    add_monetize :accounts, :debit, null: false, default: 0
  end

  def self.down
    remove_column :accounts, :credit_cents, if_exists: true
    remove_column :accounts, :credit_currency, if_exists: true

    remove_column :accounts, :debit_cents, if_exists: true
    remove_column :accounts, :debit_currency, if_exists: true
  end
end
