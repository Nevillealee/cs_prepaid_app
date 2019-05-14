class Customer < ApplicationRecord
  include Requestable

  has_many :subscriptions
  has_many :addresses
  has_many :orders

  # returns search result on customers table
  #
  # @param query [String] search parameter
  # @return [Array<ActiveRecord::Relation>] matching or all customers in asc order
  def self.search(query)
    if query
      my_query = query.strip
      if /^[a-zA-Z ]*$/.match(my_query)
        queries = my_query.split(' ')
        if queries.size > 1
          joins(:orders).where(:orders => {:status => "QUEUED"}).where("customers.first_name ilike ? AND customers.last_name ilike ?", "%#{queries[0]}%", "%#{queries[1]}%").order(first_name: :asc)
        else
          joins(:orders).where(:orders => {:status => "QUEUED"}).where("customers.first_name ilike ? OR customers.last_name ilike ? OR customers.email ilike ?",
            "%#{queries[0]}%", "%#{queries[0]}%", "%#{queries[0]}%"
          ).order(first_name: :asc).uniq
        end
      elsif /^[\d\s]+$/.match(my_query)
        joins(:orders).where(:orders => {:status => "QUEUED"}).where("customers.shopify_customer_id = ? OR id = ?", "#{my_query}", "#{my_query}").order(first_name: :asc).uniq
      end
    else
      joins(:orders).where(:orders => {:status => "QUEUED"}).order(first_name: :asc).uniq
    end
  end
end
