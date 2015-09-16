class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :create_cart

  def create_cart
    @current_cart = Cart.new(session[:cart])
  end

  def current_user
    Rails.cache.fetch("current_user-#{session[:user_id]}", expires_in: 1.day) do
      User.find(session[:user_id]) if session[:user_id]
    end
  end

  def current_borrower?
    current_user && current_user.borrower?
  end

  def all_categories
    @all_categories ||= Category.all_categories
  end
  
  helper_method :create_cart, :current_user, :current_borrower?, :all_categories
end
