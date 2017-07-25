class AddCustomerPassword < ActiveRecord::Migration[5.0]
  def change
    change_table :customers do |t|
      t.string :password_digest
      t.string :email
      t.integer :user_id
      t.integer :total_sales
    end
  end
end
