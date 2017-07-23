class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  # GET /customers
  # GET /customers.json
  def index
    @customers = Customer.all
    @sum = Customer.total_orders
    @percentage_sum = 0
    @sales_sum = 0
    if params[:sort_by]
      @sort_by = params[:sort_by]
    else
      @sort_by = "total_sales"
    end
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    @percentage_sum = 0
    @sales_sum = 0
    order = Order.new()
    if params[:sort_by]
      @sort_by = params[:sort_by]
    else
      @sort_by = "total_sales"
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:name)
    end
end
