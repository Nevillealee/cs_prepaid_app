class Customer::OrdersController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def index
    @orders = Order
    .where(
      customer_id: params[:customer_id],
      status: "QUEUED",
      scheduled_at: ((Date.today.to_time)..(Date.today.next_month.end_of_month.to_time)))
    .order('scheduled_at ASC')
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
    PaperTrail.request.whodunnit = current_user.id
    @order = Order.find(params[:id])
    all_params = {line_items: line_item_params,
                  prop_params: properties_params,
                  order_id: params[:id],
                  recharge_token: ENV['RECHARGE_TOKEN'],
                  current_user_id: current_user.id,
                 }
    recharge_line_item_update(all_params)
    redirect_to :action => "show", :id => params[:id]
  end

  # size edit form page
  def size_edit
    @order = Order.find(params[:id])
  end

  # size edit form action
  def size_update
    @order = Order.find(params[:id])
    all_params = {line_items: line_item_params,
                  prop_params: properties_params,
                  order_id: params[:id],
                  recharge_token: ENV['RECHARGE_TOKEN'],
                  current_user_id: current_user.id,
                 }
    recharge_size_update(all_params)
    redirect_to :action => "show", :id => params[:id]
  end



  def line_item_params
    params.require(:line_items).permit(
      :sku,
      :grams,
      :price,
      :title,
      :images,
      :quantity,
      :product_title,
      :variant_title,
      :subscription_id,
      :shopify_product_id,
      :shopify_variant_id,
      :product_id,
      :variant_id
    )
  end

  def properties_params
    params.require(:properties).permit(
      :charge_interval_frequency,
      :charge_interval_unit_type,
      :gloves,
      :leggings,
      :"main-product",
      :"sports-jacket",
      :product_collection,
      :product_id,
      :referrer,
      :shipping_interval_frequency,
      :shipping_interval_unit_type,
      :"sports-bra",
      :tops,
      :unique_identifier
    )
  end

  def recharge_line_item_update(arg)
    Resque.enqueue(OrderUpdate, arg)
  end

  def recharge_size_update(arg)
    Resque.enqueue(OrderSizeUpdate, arg)
  end
end
