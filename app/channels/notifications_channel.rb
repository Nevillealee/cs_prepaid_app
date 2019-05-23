class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    # stream_from "notifications:#{current_user.id}"
    stream_from "notifications:size_change"
    stream_from "notifications:product_switch"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
