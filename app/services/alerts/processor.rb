# frozen_string_literal: true

module Alerts
  class Processor
    NOT_FOUND = 'not_found'
    FOUND = 'found'
    CONSIDER_NOT_FOUND_AFTER = 15.minutes

    def self.call(alert, bot)
      new(alert, bot).call
    end

    def initialize(alert, bot)
      @alert = alert
      @bot = bot
    end

    def call
      @info = fetch_plane_info

      LOGGER.debug("Found trace for #{alert.icao}")

      plane_seen_recently!
      process_alert
    rescue AirplaneFinder::IcaoNotFoundError, AirplaneFinder::TraceNotFoundError
      LOGGER.debug("#{alert.icao} not found")
      alert.update(last_check_details: NOT_FOUND)
    ensure
      alert.update(last_check_at: Time.now)
    end

    private

    attr_reader :alert, :bot, :info

    def fetch_plane_info
      REDIS_CACHE.fetch("airplane_info|#{alert.icao}", expires_in: 30.seconds) do
        AirplaneFinder.new(alert.icao).get_recent_trace
      end
    end

    def process_alert
      # Only alerts when plane goees from "not_found" to "found"
      if alert.last_check_details != NOT_FOUND
        LOGGER.debug("Exiting the alert has #{alert.icao} was still found last iteration")
        return
      end

      send_messages
    end

    def plane_seen_recently!
      time_without_data = (Time.now - info.last_data_received).seconds

      return unless time_without_data > CONSIDER_NOT_FOUND_AFTER

      LOGGER.debug("#{alert.icao} was last seen at #{time_without_data.in_minutes.to_i}min ago")
      raise AirplaneFinder::TraceNotFoundError
    end

    def send_messages
      LOGGER.debug("Sending alerts for #{alert.icao}")
      bot.api.send_message(**message_builder.build_message)
      bot.api.send_location(**message_builder.build_location)

      alert.update(last_alert_sent_at: Time.now, last_check_details: FOUND)
      alert.increment_alerts!
    end

    def message_builder
      @message_builder ||= Builder::Telegram.new(alert, info)
    end
  end
end
