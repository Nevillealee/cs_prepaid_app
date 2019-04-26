class CustomersController < ApplicationController
  before_action :authenticate_user!

  def index
    @customers = Customer.order(first_name: :asc)
  end

  def search
    if query_params[:q]
      @customers = Customer.search(query_params)
      render :index
    else
      @customers = Customer.order(first_name: :asc)
    end
  end

  def show
    @customer = Customer.first
  end

  private

  def query_params
    params.permit(:q)
  end
end
