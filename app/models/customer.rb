require 'csv'
class Customer < ApplicationRecord
  has_many :orders
  has_many :comparisons
  has_secure_password

  def sim_pearson(customer2)
    si={}
    cs2_orders = []
    customer2.orders.each do |order|
      cs2_orders.push(order.model)
    end
    self.orders.each do |order|
      if cs2_orders.include?(order.model)
        si[order.model]=1
      end
    end

    n = si.length

    if n == 0; return 0 end

    sum1 = 0
    sum2 = 0
    sum1Sq = 0
    sum2Sq = 0
    pSum = 0
    si.each do |model|
      c1_price = self.orders.find_by_model(model).amount
      c2_price = customer2.orders.find_by_model(model).amount
      sum1 += c1_price
      sum2 += c2_price
      sum1Sq += c1_price ** 2
      sum2Sq += c2_price ** 2
      pSum += (c1_price * c2_price)
    end

    num = pSum-(sum1*sum2/n)
    den = Math.sqrt((sum1Sq-(sum1 ** 2)/n)*(sum2Sq-(sum2 ** 2)/n))
    if den == 0; return 0 end

    r = num/den
  end

  def compare
    comps = {}
    Customer.all.each do |customer|
      if customer.id != self.id
        sp = self.sim_pearson(customer)
        comps[customer.name] = sp
      end
    end
    comps.sort_by {|customer, value| value}.reverse
  end

  def get_recommended_items
    totals = {}
    sim_sums = {}

    Customer.all.each do |customer|
      if customer.id != self.id
        sim = sim_pearson(customer)
        if sim > 0
          self.missing_items(customer).each do |item|
            totals[item[0]]? totals[item[0]]+= item[1]*sim : totals[item[0]] = item[1]*sim
            sim_sums[item[0]]? sim_sums[item[0]]+=sim : sim_sums[item[0]] = sim
          end
        end
      end
    end

    rankings = []
    totals.each do |item, total|
      if item != "PALLET/"
        rankings.push({item => total/sim_sums[item]})
      end
    end
    rankings.sort_by! {|ranking| ranking.values.first}.reverse!.shift(25)
  end

  def missing_items(customer2)
    c1_orders = []
    mi = {}
    mi_returned = {}
    c2_total_sales = customer2.get_total_orders
    self.orders.each do |order|
      c1_orders.push(order.model)
    end

    customer2.orders.each do |order|
      if !c1_orders.include?(order.model)
        mi[order.model] = (customer2.orders.find_by_model(order.model).amount / c2_total_sales)
      end
    end
    mi.sort_by {|model, value| value}.reverse.each do |arr|
      mi_returned[arr[0]] = arr[1]
    end
    mi_returned
  end

  def self.kcluster(k)
    #determine min and max of each point
    ranges = []
    csv_text = File.read("customer_matrix.csv")
    csv = CSV.parse(csv_text, :headers => true)
    (csv[0].length - 1).times do |i|
      min = 0
      max = 0
      csv.each do |row|
        if row[i + 1].to_f > max; max = row[i + 1].to_f end
        if row[i + 1].to_f < min; min = row[i + 1].to_f end
      end
      ranges.push([min, max])
    end

    clusters = []
    k.times do |time|
      clusters.push([])
      ranges.each do |range|
        cluster = rand*(range[1] - range[0]) + range[0]
        clusters[time].push(cluster)
      end
    end

    last_matches = []
    best_matches = nil
    100.times do |i|
      best_matches = []
      k.times do
        best_matches.push([])
      end
      puts "iteration #{i + 1}"
      csv.each_with_index do |row, index|
        best_match = 0
        k.times do |time|
          d = Customer.distance(clusters[time], row)
          if d < Customer.distance(clusters[best_match], row)
            best_match = time
          end
        end
        best_matches[best_match].push(index)
      end

      if best_matches == last_matches
        break
      else
        last_matches = best_matches
      end

      avgs = []
      k.times do |time|
        avgs = []
        if best_matches[time].length > 0
          (csv[0].length - 1).times do |index|
            sum = 0
            best_matches[time].each do |i|
              sum += csv[i][index + 1].to_f
            end
            avgs[index] = sum/best_matches[time].length
          end
        end
      clusters[time] = avgs
      end
    end
    arr =[]
    best_matches.each_with_index do |match_arr, i|
      arr.push([])
      match_arr.each do |match|
        arr[i].push(Customer.find(csv[match][0].to_i).name.titleize)
      end
    end
    arr
  end

  def self.distance(cluster, customer_values)
    sum1 = 0
    sum1Sq = 0
    sum2 = 0
    sum2Sq = 0
    pSum = 0
    cluster.length.times do |time|
      sum1 += cluster[time]
      sum1Sq += cluster[time] ** 2
      sum2 += customer_values[time + 1].to_f
      sum2Sq += customer_values[time + 1].to_f ** 2
      pSum += cluster[time] * customer_values[time + 1].to_f
    end

    num = pSum - sum1 * sum2 /cluster.length
    den = Math.sqrt((sum1Sq - (sum1 ** 2)/cluster.length) * (sum2Sq - (sum2 ** 2)/cluster.length))
    if den == 0; return 0 end;
    return 1 - num/den
  end

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

  def self.write_matrix
    models = ["customer_id"]
    Order.all.each do |order|
      if !models.include?(order.model)
        models.push(order.model)
      end
    end
    CSV.open("customer_matrix.csv", "wb") do |csv|
      csv << models
      Customer.all.each do |customer|
        arr = []
        arr.push(customer.id)
        models.each do |model|
          order = customer.orders.find_by_model(model)
          if order != nil
            arr.push(order.amount)
          else
            arr.push(0)
          end
        end
        arr.push("\n")
        csv << arr
      end
    end
  end

  def self.read_matrix
    csv_text = File.read("customer_matrix.csv")
    csv = CSV.parse(csv_text, :headers => true)
    arr = []
    csv.each do |row|
      arr.push(row["customer_id"])
    end
    arr
  end
end
