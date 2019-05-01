class CustomersController < ApplicationController
  before_action :authenticate_user!

  def index
    @customers = Customer.search(query_params[:q])
  end

  def show
    @customer = Customer.first
  end

  private

  def query_params
    params.permit(:q)
  end
end
