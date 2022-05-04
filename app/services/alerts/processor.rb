
module Alerts
  class Processor
    def self.call(alert, bot)
      new(alert, bot).call
    end

    def initialize(alert, bot)
      @alert = alert
      @bot = bot
    end

    def call
      @info = AirplaneFinder.new(alert.icao).get_recent_trace

      send_alert(info)
    rescue AirplaneFinder::IcaoNotFoundError, AirplaneFinder::TraceNotFoundError
      alert.update(last_check_details: "not_found")
    ensure
      alert.update(last_check_at: Time.now)
    end

    private

    attr_reader :alert, :bot, :info

    def send_alert(info)
      # Only alerts when plane goees from "not_found" to "found"
      return unless alert.last_check_details == "not_found"

      bot.api.send_message(**message_builder.build_message)
      bot.api.send_location(**message_builder.build_location)

      alert.update(last_alert_sent_at: Time.now, last_check_details: "found")
    end

    def message_builder
      @message_builder ||= MessageBuilder.new(alert, info)
    end
  end
end
