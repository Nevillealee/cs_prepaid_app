module TwentyFive
  def twenty_five_min
    min_ago = 25
    minutes_ago = DateTime.now.in_time_zone - (min_ago/1440.0)
    puts "running configure timezone: #{Time.zone.inspect}"
    twenty_five_minutes_ago_str = minutes_ago.strftime("%Y-%m-%dT%H:%M:%S")
    puts "Twenty five minutes ago = #{twenty_five_minutes_ago_str}"
    Resque.logger.info "Twenty five minutes ago = #{twenty_five_minutes_ago_str}"
    return twenty_five_minutes_ago_str
  end
end
