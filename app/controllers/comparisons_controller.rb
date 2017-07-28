class ComparisonsController < ApplicationController
  before_action :set_customer
  def index
    @comparisons = @customer.comparisons
  end

  def show
    @comparison_customer = Customer.find(params[:id])
    @missing_items = @customer.missing_items(@comparison_customer)
  end

private
  def set_customer
    @customer = Customer.find(params[:customer_id])
  end
end
