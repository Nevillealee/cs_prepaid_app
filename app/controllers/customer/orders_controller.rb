class Customer::OrdersController < ApplicationController
  # before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def index
    @orders = Order.where(customer_id: params[:customer_id],  status: "QUEUED")
  end

  def show
    @order = Order.find_by(id: params[:id], status: "QUEUED")
  end

  def edit
    # page where cs can enter order changes
    @order = Order.find(params[:id])
  end

  # activates if order.exists?
  def update
    @order = Order.find(params[:id])
    puts params.inspect
    # if true
    #    @order.update_attributes(order_params)
    #   ext_update(order_params)
    # else
    #   render 'edit'
    # end
    render 'edit'
  end

  private

  def order_params
    params.require(:properties).permit(:id, :customer_id, :properties)
  end

  def ext_update(arg)
    Resque.enqueue(OrderUpdate, arg)
  end
end
