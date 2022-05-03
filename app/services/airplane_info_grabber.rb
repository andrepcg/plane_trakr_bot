require 'open-uri'
require 'oj'

class AirplaneInfoGrabber
  def initialize(icao)
    @icao = icao.downcase
  end

  def call

  end

  def get_recent_trace
    url = "https://globe.adsbexchange.com/data/traces/#{icao[-2..]}/trace_recent_#{icao}.json"
    info = load_json(url, "Referer" => "https://globe.adsbexchange.com")
    # AirplaneTrace.new(**info)
  rescue OpenURI::HTTPError => e
    nil
  end

  private

  attr_reader :icao

  def load_json(url, options = {})
    res = URI.open(url, options, &:read)

    Oj.load(res)
  end
end
