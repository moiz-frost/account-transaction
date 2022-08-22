class AddUniqueIndexesToAccount < ActiveRecord::Migration[6.0]
  def change
    add_index :accounts, :email, unique: true unless index_exists? :accounts, :email
    add_index :accounts, :phone_number, unique: true unless index_exists? :accounts, :phone_number
  end
end
