class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticated?

  def authenticated?
    if session[:customer_id] || session[:user_id]
      true
    else
      redirect_to new_login_path
    end
  end
end
