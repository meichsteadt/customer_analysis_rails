require 'csv'
class Order < ApplicationRecord
  belongs_to :customer

  def get_similar_orders(order2)
    sc={}
    order2_customers = []

    Customer.all.each do |customer|
      if customer.orders.find_by_model(self.model) && customer.orders.find_by_model(order2.model)
        sc[customer.name] = customer.id
      end
    end

    n = sc.length

    if n == 0; return 0 end

    sum1 = 0
    sum2 = 0
    sum1Sq = 0
    sum2Sq = 0
    pSum = 0
    sc.each do |model|
      item1_price = Customer.find(model[1]).orders.find_by_model(self.model).amount
      item2_price = Customer.find(model[1]).orders.find_by_model(order2.model).amount
      sum1 += item1_price
      sum2 += item2_price
      sum1Sq += item1_price ** 2
      sum2Sq += item2_price ** 2
      pSum += (item1_price * item2_price)
      binding.pry
    end

    num = pSum-(sum1*sum2/n)
    den = Math.sqrt((sum1Sq-(sum1 ** 2)/n)*(sum2Sq-(sum2 ** 2)/n))
    if den == 0; return 0 end

    r = num/den
  end

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
