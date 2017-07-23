require 'csv'
class Order < ApplicationRecord
  belongs_to :customer

  def self.get_orders
    customers = {
      "1":	1,
      "2":	2,
      "4":	3,
      "5":	4,
      "6":	5,
      "7":	6,
      "8":	7,
      "9":	8,
      "20":	9,
      "21":	10,
      "22":	11,
      "23":	12,
      "24":	13,
      "25":	14,
      "26":	15,
      "27":	16,
      "28":	17,
      "29":	18,
      "30":	19,
      "31":	20,
      "32":	21
    }

    csv_text = File.read("customer_orders.csv")
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      id = row["customer_id"]
      customer = Customer.find(customers[:"#{id}"])
      amount = row["order_price"]
      if amount.include? ","
        amount.sub!(",", "")
      end
      customer.orders.create(model: row['model'], amount: amount.to_f)
    end
  end
end
