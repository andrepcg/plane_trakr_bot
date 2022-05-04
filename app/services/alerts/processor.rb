# frozen_string_literal: true

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
      @info = get_plane_info

      LOGGER.debug("#{alert.icao} found")

      process_alert
    rescue AirplaneFinder::IcaoNotFoundError, AirplaneFinder::TraceNotFoundError
      LOGGER.debug("#{alert.icao} not found")
      alert.update(last_check_details: 'not_found')
    ensure
      alert.update(last_check_at: Time.now)
    end

    private

    attr_reader :alert, :bot, :info

    def get_plane_info
      REDIS_CACHE.fetch("airplane_info|#{alert.icao}", expires_in: 30.seconds) do
        AirplaneFinder.new(alert.icao).get_recent_trace
      end
    end

    def process_alert
      # Only alerts when plane goees from "not_found" to "found"
      if alert.last_check_details != 'not_found'
        LOGGER.debug("Exiting the alert has #{alert.icao} was still found last iteration")
        return
      end

      send_messages
    end

    def send_messages
      LOGGER.debug("Sending alerts for #{alert.icao}")
      bot.api.send_message(**message_builder.build_message)
      bot.api.send_location(**message_builder.build_location)

      alert.update(last_alert_sent_at: Time.now, last_check_details: 'found')
      alert.increment_alerts!
    end

    def message_builder
      @message_builder ||= MessageBuilder.new(alert, info)
    end
  end
end
