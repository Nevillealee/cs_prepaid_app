# frozen_string_literal: true

class Customer < ApplicationRecord
  include Requestable

  has_many :subscriptions
  has_many :addresses
  has_many :orders

  def self.search(params)
    my_query = params[:q].strip
    if /^[a-zA-Z ]*$/.match(my_query)
      queries = my_query.split(' ')
      if queries.size > 1
        where("first_name ilike ? AND last_name ilike ?", "%#{queries[0]}%", "%#{queries[1]}%").order(first_name: :asc)
      else
        where("first_name ilike ? OR last_name ilike ? OR email ilike ?",
          "%#{queries[0]}%", "%#{queries[0]}%", "%#{queries[0]}%"
        ).order(first_name: :asc)
      end
    elsif /^[\d\s]+$/.match(my_query)
      where("shopify_customer_id = ? OR id = ?", "#{my_query}", "#{my_query}").order(first_name: :asc)
    else
      order(first_name: :asc)
    end
  end # end of self.search
end
