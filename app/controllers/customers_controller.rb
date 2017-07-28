class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :edit, :update, :destroy]
  before_action :user?, only: [:index]
  # GET /customers
  # GET /customers.json
  def index
    @customers = Customer.where(user_id: session[:user_id])
    @sum = Customer.total_orders.to_f
    @percentage_sum = 0
    @sales_sum = 0
    if params[:sort_by]
      @sort_by = params[:sort_by]
    else
      @sort_by = "total_sales"
    end
    respond_to do |format|
      format.json {
        render :json => @customers.sort_by {|customer| customer.total_sales}.reverse
      }
      format.html
      format.js
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

    def user?
      if session[:user_id]
        true
      else
        flash[:notice] = "You're not authorized to see that page"
        redirect_to customer_path(session[:customer_id])
      end
    end
end
