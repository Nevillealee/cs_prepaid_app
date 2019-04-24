class CustomerController < ApplicationController
  before_action :authenticate_user!

  def index
    @customers = Customer.all
  end

  def search
    # query customers here with sanitized params
  end

  def show
    @customer = Customer.first
  end
end
