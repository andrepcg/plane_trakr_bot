# frozen_string_literal: true

module Alerts
  module Builder
    class Base
      def initialize(alert, airplane_info)
        @alert = alert
        @airplane_info = airplane_info
      end

      def build_message
        raise 'implement in child'
      end

      def build_location
        raise 'implement in child'
      end

      private

      attr_reader :alert, :airplane_info

      def aircraft_last_data_minutes
        (Time.now - airplane_info.last_data_received).seconds.in_minutes.to_i
      end

      def adsb_exchange_link
        "https://globe.adsbexchange.com/?icao=#{alert.icao}"
      end
    end
  end
end
