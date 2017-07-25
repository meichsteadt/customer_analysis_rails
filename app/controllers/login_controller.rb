class LoginController < ApplicationController
  skip_before_action :authenticated?

  def new

  end

  def create
    @user = User.find_by_email(params[:email])
    if  @user && @user.authenticate(params[:password])
        session[:user_id] = @user.id
        redirect_to customers_path()
    else
      @customer = Customer.find_by_email(params[:email])
      if @customer && @customer.authenticate(params[:password])
        session[:customer_id] = @customer.id
        redirect_to customer_path(@customer)
      else
        flash[:alert] = "Email and password were incorrect"
        redirect_to new_login_path
      end
    end
  end

  def destroy
    session[:user_id] = nil
    session[:customer_id] = nil
    redirect_to new_login_path
  end
end
