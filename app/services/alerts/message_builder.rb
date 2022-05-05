# frozen_string_literal: true

module Alerts
  class MessageBuilder
    def initialize(alert, airplane_info)
      @alert = alert
      @airplane_info = airplane_info
    end

    def build_message
      ago = (Time.now - airplane_info.last_data_received).seconds.in_minutes.to_i
      {
        chat_id: alert.chat_id,
        text: "You're being alerted for #{alert.name}! The plane was found recently (#{ago} minutes ago)."
      }
    end

    def build_location
      lat, lng = airplane_info.last_location
      {
        chat_id: alert.chat_id,
        latitude: lat,
        longitude: lng,
        reply_markup: link_markup
      }
    end

    private

    attr_reader :alert, :airplane_info

    def link_markup
      kb = [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: 'Go to ADS-B Exchange', url: "https://globe.adsbexchange.com/?icao=#{alert.icao}"
        )
      ]
      Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
    end
  end
end
