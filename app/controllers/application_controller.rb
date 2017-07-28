class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticated?

  def authenticated?
    if session[:customer_id] || session[:user_id]
      session[:user_id]? @user = User.find(session[:user_id]) : @customer = Customer.find(session[:customer_id])
    else
      redirect_to new_login_path
    end
  end
end
