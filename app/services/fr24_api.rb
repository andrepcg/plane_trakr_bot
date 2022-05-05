# frozen_string_literal: true

class Fr24Api
  URL = 'https://www.flightradar24.com/v1/search/web/find?query={QUERY}&limit=10'
  URL_Q = '{QUERY}'

  def self.fetch_registration(value)
    res = JsonLoader.load(URL.gsub(URL_Q, value))
    return unless res['results'].size.positive?

    record = res['results'].detect { |r| r['type'] == 'live' }
    return unless record

    record['detail']['reg']
  end

  def self.fetch_icao(value)
    res = JsonLoader.load(URL.gsub(URL_Q, value))
    return unless res['results'].size.positive?

    record = res['results'].detect { |r| r['type'] == 'aircraft' }
    return unless record

    record['detail']['hex']
  end
end
