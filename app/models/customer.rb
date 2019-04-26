# frozen_string_literal: true

class Customer < ApplicationRecord
  include Requestable

  has_many :subscriptions
  has_many :addresses
  has_many :orders

  def self.search(params)
    params[:q].strip!
    if !/\A\d+\z/.match(params[:q])
      queries = params[:q].split(' ')
      if queries.size > 1
        where("first_name ilike ? AND last_name ilike ?", "%#{queries[0]}%", "%#{queries[1]}%").order(first_name: :asc)
      else
        where("first_name ilike ? OR last_name ilike ? OR email ilike ?",
          "%#{queries[0]}%", "%#{queries[0]}%", "%#{queries[0]}%"
        ).order(first_name: :asc)
      end
    elsif /\A\d+\z/.match(params[:q])
      where("shopify_customer_id = ? OR id = ?", "#{params[:q]}", "#{params[:q]}").order(first_name: :asc)
    else
      order(first_name: :asc)
    end
  end # end of self.search
end
