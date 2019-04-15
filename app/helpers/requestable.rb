module Requestable
  Resque.logger = Logger.new(STDOUT)

  def fetch(params)

  end

  def api_count(params)
    recharge_header = {
      'X-Recharge-Access-Token' => params['X-Recharge-Access-Token'],
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
    }
    object_name = self.entity_name
    my_response = HTTParty.get("https://api.rechargeapps.com/#{object_name}s/count?",
                                :headers => recharge_header)
    my_count = my_response['count'].to_i
    Resque.logger.info "#{my_count} #{object_name}'s on Recharge API"
    Resque.logger.debug my_response
    return my_count
  end

  # return class name (matched with api objects) for http arguement interpolation
  def entity_name
    self.is_a?(Module) ? name.downcase : self.class.name.downcase
  end
end
