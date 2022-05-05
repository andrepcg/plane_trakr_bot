# frozen_string_literal: true

class CallsignHandler
  class << self
    # returns registration ID
    def search(value)
      v = value.upcase
      REDIS_CACHE.fetch("callsign_handler|#{v}", expires_in: 30.seconds) do
        Fr24Api.fetch_registration(v)
      end
    end
  end
end
