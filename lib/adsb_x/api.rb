# frozen_string_literal: true

require 'oj'

module AdsbX
  class TraceNotFoundError < StandardError; end

  class Api
    HEADERS = {
      'Accept' => '*/*',
      'Accept-Encoding' => 'application/json',
      'Accept-Language' => 'en-US,en;q=0.9',
      'Referer' => 'https://globe.adsbexchange.com/',
      'Sec-Fetch-Dest' => 'empty',
      'Sec-Fetch-Mode' => 'cors',
      'Sec-Fetch-Site' => 'same-origin',
      'Sec-Gpc' => '1',
      'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:15.0) Gecko/20100101 Firefox/15.0.1',
      'X-Requested-With' => 'XMLHttpRequest'
    }.freeze
    BASE_URL = 'https://globe.adsbexchange.com'

    def recent_trace(icao)
      url = "#{BASE_URL}/data/traces/#{icao.downcase[-2..]}/trace_recent_#{icao.downcase}.json"
      response = HTTP.headers(HEADERS).get(url)

      raise TraceNotFoundError, 'Trace not found' unless response.status.success?

      Trace.build_from_trace(Oj.load(response))
    end

    def history_trace(icao, date)
      day = date.strftime('%d')
      month = date.strftime('%m')
      url = "#{BASE_URL}/globe_history/#{date.year}/#{month}/#{day}/traces/#{icao.downcase[-2..]}/trace_full_#{icao.downcase}.json"
      response = HTTP.headers(HEADERS).get(url)

      raise TraceNotFoundError, 'Trace not found' unless response.status.success?

      Trace.build_from_trace(Oj.load(response))
    end
  end
end
