# frozen_string_literal: true
module Requestable
  Resque.logger = Logger.new(STDOUT)
  HEADER = {
    'X-Recharge-Access-Token' => ENV['RECHARGE_ACTIVE_TOKEN'],
    'Accept' => 'application/json',
    'Content-Type' => 'application/json',
  }.freeze
  BATCH_SIZE = 40
  REDIS_EXPIRATION = 3600

  # returns 1D hash array of all entities from ReCharge
  def fetch(params)
    Resque.logger.debug "Requestable.fetch received #{params.inspect}"
    past = Time.now
    total = api_count(params)
    remain_requests = (total/250.to_f).ceil
    Resque.logger.debug "pages to request total: #{remain_requests}"
    batch_num = (remain_requests / BATCH_SIZE.to_f).ceil
    Resque.logger.debug "batch number: #{batch_num}"
    chap_start = 1
    chap_end = 0
    entity = params.fetch(:entity)
    Resque.logger.debug "entity name: #{entity}"
    cache = $redis
    pages = []
    batch_num.times do
      if remain_requests > BATCH_SIZE
        chap_end += BATCH_SIZE
        remain_requests -= BATCH_SIZE
      else
        chap_end += remain_requests
      end
      hydra = Typhoeus::Hydra.new(max_concurrency: 20)
      chap_start.upto(chap_end) do |page|
        pages << page
        # queue up current batch
        request = Typhoeus::Request.new(
          "https://api.rechargeapps.com/#{entity}s?#{params[:query]}&limit=250&page=#{page}",
          # followlocation: true,
          headers: HEADER
        )
        # error logging callbacks
        request.on_complete do |res|
          if res.success?
            puts "#{entity.upcase} request queued"
          elsif res.timed_out?
            Resque.logger.error "TIMED OUT: #{res.response_headers}"
          elsif res.code.zero?
            Resque.logger.error "Couldnt get an http response #{res.return_message}"
          else
            Resque.logger.error("HTTP request failed: #{res.code}")
          end
        end

        request.on_success do |res|
          @used = res.headers['x-recharge-limit'].to_i
          Resque.logger.debug res.headers['x-recharge-limit']
          # REDIS HGET -> e.g. order_pull:20190422:001"
          # key=order_pull:20190422, field= 3 digit page num: "001-250"
          key = "#{entity}_pull:#{Time.now.strftime("%Y%m%d")}#{page.to_s.rjust(3, '0')}"
          # cache array of entitys as json in REDIS
          hash_set(cache, key, res.response_body)
        end

        hydra.queue(request)
        chap_start = chap_end
      end
      hydra.run
      batch_throttle(@used)
    end
    Resque.logger.debug "Pages iterated: #{pages.inspect}"
    # cache.flatten!
    Resque.logger.info("RUN TIME per #{total} records: #{(Time.now - past)}")
    # Resque.logger.info "cache has #{cache.size} hashes"
    # return cache
  end

  def api_count(args)
    query_str = args[:query]
    object_name = args[:entity]
    my_response = HTTParty.get("https://api.rechargeapps.com/#{object_name}s/count?#{query_str}",
                                headers: HEADER)
    my_count = my_response['count'].to_i
    Resque.logger.info "#{my_count} #{object_name}'s on Recharge API"
    Resque.logger.debug my_response
    my_count
  end

  def batch_throttle(requests_used)
    if requests_used > 20
      puts 'sleeping 20'
      sleep 10
    end
  end
  # return class name (matched with api objects) for http arguement interpolation
  def entity_name
    self.is_a?(Module) ? name.downcase : self.class.name.downcase
  end

  def hash_get_key_field(key)
    s = key.split(":")
    puts "s = #{s}"
    if s[1].length > 3
        {:key => s[0]+":"+s[1][0..-4], :field => s[1][-3..-1]}
    else
        {:key => s[0]+":", :field => s[1]}
    end
  end

  def hash_set(r,key,value)
    kf = hash_get_key_field(key)
    r.hset(kf[:key],kf[:field],value)
    r.expire(kf[:key], REDIS_EXPIRATION)
    Resque.logger.info "REDIS HSET KF: #{kf[:key]}:#{kf[:field]}"
    Resque.logger.info "REDIS #{kf[:key]} hash fields now: #{r.hkeys(kf[:key])}"
  end

  def hash_get(key)
    kf = hash_get_key_field(key)
    r = $redis
    r.hget(kf[:key],kf[:field])
  end

  def hash_get_all(key)
    r = $redis
    r.hgetall(key)
  end

end
