
class CallsignHandler
  class << self
    # returns registration ID
    def search(value)
      get_registration_from_callsign(value)
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