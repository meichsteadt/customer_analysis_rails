class CreateComparisons < ActiveRecord::Migration[5.0]
  def change
    create_table :comparisons do |t|
      t.string :customer_name
      t.integer :customer_id
      t.float :sim_pearson

      t.timestamps
    end
  end
end
