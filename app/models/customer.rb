require 'csv'
class Customer < ApplicationRecord
  has_many :orders
  has_secure_password

  def self.get_customers
    csv_text = File.read("customers.csv")
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      Customer.create(name: row['customer_name'])
    end
  end

  def get_total_orders
    sum = 0
    self.orders.each do |order|
      sum += order.amount
    end
    sum
  end

  def self.total_orders
    sum = 0
    Customer.all.each do |customer|
      sum += customer.total_sales
    end
    sum
  end
end
