class Comparison < ApplicationRecord
  belongs_to :customer
  def self.get_comparisons
    Customer.all.each do |customer|
      comps = customer.compare
      comps.each do |comp|
        customer.comparisons.create(customer_name: comp[0], sim_pearson: comp[1])
      end
    end
  end
end
