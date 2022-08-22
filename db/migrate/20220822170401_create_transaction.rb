class CreateTransaction < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.references :account, index: true, foreign_key: true
      t.integer :type, null: false
      t.monetize :amount, null: false, default: 0

      t.timestamps
    end
  end
end
