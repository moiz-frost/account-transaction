class AddEventToTransaction < ActiveRecord::Migration[6.0]
  def change
    add_column :transactions, :event, :integer, null: false, default: 0
  end
end
