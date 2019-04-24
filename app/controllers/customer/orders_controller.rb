class Customer::OrdersController < ApplicationController
  before_action :authenticate_user!

  def show
    @orders = Order.where(customer_id: params[:id])
  end

  def edit
  end

  def update
  end

end
