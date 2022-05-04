# frozen_string_literal: true

module Alerts
  class Creator
    def self.create(reg_or_icao, message)
      new(reg_or_icao, message).call
    end

    def initialize(reg_or_icao, message)
      @reg_or_icao = reg_or_icao
      @message = message
    end

    def call
      Alert.create(
        icao: icao,
        registration: registration,
        created_at: Time.now,
        chat_id: @message.chat.id,
        chat_username: @message.from.username
      )
    end

    private

    def icao?
      @reg_or_icao.upcase == icao
    end

    def airplane_info
      @airplane_info ||= AirplaneFinder.new(@reg_or_icao)
    end

    def registration
      airplane_info.registration
    end

    def icao
      airplane_info.icao
    end
  end
end
