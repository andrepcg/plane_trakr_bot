# frozen_string_literal: true

require 'oj'

module Fr24
  class RequestError < StandardError; end

  class Api
    BASE_URL = 'https://www.flightradar24.com/v1/search/web/find?query={QUERY}&limit=10'
    URL_Q = '{QUERY}'

    def fetch_registration(value)
      res = load(value)
      return unless res['results'].size.positive?

      record = find_record_type(res, 'live')
      return record['detail']['reg'] if record

      record = find_record_type(res, 'aircraft')
      return unless record

      record['id']
    end

    def fetch_icao(value)
      res = load(value)
      return unless res['results'].size.positive?

      record = find_record_type(res, 'aircraft')
      return unless record

      record['detail']['hex']
    end

    private

    def load(value)
      response = HTTP.get(BASE_URL.gsub(URL_Q, value))

      raise RequestError, 'Request error' unless response.status.success?

      Oj.load(response)
    end

    def find_record_type(result, type)
      result['results'].detect { |r| r['type'] == type }
    end
  end
end
