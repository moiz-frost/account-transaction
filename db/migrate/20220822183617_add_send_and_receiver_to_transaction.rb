class AddSendAndReceiverToTransaction < ActiveRecord::Migration[6.0]
  def change
    add_reference :transactions, :sender, foreign_key: { to_table: :accounts }, null: true
    add_reference :transactions, :receiver, foreign_key: { to_table: :accounts }, null: true
  end
end
