
class CallsignHandler
  class << self
    # returns registration ID
    def search(value)
      v = value.upcase
      REDIS_CACHE.fetch("callsign_handler|#{v}", expires_in: 30.seconds) do
        get_registration_from_callsign(v)
      end
    end

    private

    def get_registration_from_callsign(value)
      res = JsonLoader.load("https://www.flightradar24.com/v1/search/web/find?query=#{value.upcase}&limit=10")
      return unless res["results"].size > 0

      record = res["results"].select { |r| r["type"] == "live" }
      return unless record

      record["detail"]["reg"]
    end
  end
end