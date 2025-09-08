class AddUserIdToCarts < ActiveRecord::Migration[7.1]
  def change
    add_reference :carts, :user, foreign_key: true, null: true
  end
end