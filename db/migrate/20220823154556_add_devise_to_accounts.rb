# frozen_string_literal: true

class AddDeviseToAccounts < ActiveRecord::Migration[6.0]
  def change
    change_table :accounts do |t|
      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ''
    end
  end
end
