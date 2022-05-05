# frozen_string_literal: true

require 'telegram/bot'

module Alerts
  module Builder
    class Telegram < Base
      def build_message
        {
          chat_id: alert.chat_id,
          text: "You're being alerted for #{alert.name}! The plane was found " \
                "recently (#{aircraft_last_data_minutes} minutes ago)."
        }
      end

      def build_location
        lat, lng = airplane_info.last_location
        {
          chat_id: alert.chat_id,
          latitude: lat,
          longitude: lng,
          reply_markup: link_markup,
          disable_notification: true
        }
      end

      private

      def link_markup
        kb = [
          ::Telegram::Bot::Types::InlineKeyboardButton.new(
            text: 'Go to ADS-B Exchange', url: adsb_exchange_link
          ),
          ::Telegram::Bot::Types::InlineKeyboardButton.new(
            text: 'Remove alert', callback_data: "delete_#{alert.id}"
          )
        ]
        ::Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      end
    end
  end
end
