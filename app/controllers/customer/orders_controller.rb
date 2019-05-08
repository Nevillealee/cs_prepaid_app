class Customer::OrdersController < ApplicationController
  # before_action :authenticate_user!
  # skip_before_action :verify_authenticity_token

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
    if true # @order.update_attributes(order_params)
      all_params = {line_items: line_item_params,
                    prop_params: properties_params,
                    order_id: params[:id],
                    recharge_token: ENV['RECHARGE_STAGING_TOKEN'],
                   }
      recharge_line_item_update(all_params)
      # redirect_back(fallback_location: root_path)
    else
      render 'edit'
    end
  end
  # size edit form page
  def size_edit
    @order = Order.find(params[:id])
  end

  # size edit form action
  def size_update
    if true # @order.update_attributes(order_params)
      all_params = {line_items: line_item_params,
                    prop_params: properties_params,
                    order_id: params[:id],
                    recharge_token: ENV['RECHARGE_STAGING_TOKEN'],
                   }
      recharge_size_update(all_params)
      # redirect_back(fallback_location: root_path)
    else
      render 'size_edit'
    end
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
      :shopify_variant_id
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
    OrderUpdate.perform_later(arg)
  end

  def recharge_size_update(arg)
    OrderSizeUpdate.perform_later(arg)
  end
end
