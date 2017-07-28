class RecommendationsController < ApplicationController
  def index
    @customer = Customer.find(params[:customer_id])
    @recommendations = @customer.get_recommended_items
  end
end
