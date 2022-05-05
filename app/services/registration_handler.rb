# frozen_string_literal: true

require 'open-uri'
require 'oj'

class RegistrationHandler
  BASE_URL = 'https://globe.adsbexchange.com'
  REG_ICAO_FILE = 'reg_icao.json'
  CACHE_TIME = 1.hour

  class << self
    def load
      @reg_icao_cache = load_reg_icao
    end

    def registration_from_icao(value)
      raise "Registration hasn't been loaded" unless @reg_icao_cache

      @reg_icao_cache.key(value.upcase)
    end

    def icao_from_registration(value)
      raise "Registration hasn't been loaded" unless @reg_icao_cache

      @reg_icao_cache[value.upcase]&.upcase || get_icao_from_fr24(value)
    end

    private

    def get_icao_from_fr24(value)
      res = JsonLoader.load("https://www.flightradar24.com/v1/search/web/find?query=#{value.upcase}&limit=10")
      return unless res['results'].size.positive?

      record = res['results'].detect { |r| r['type'] == 'aircraft' }
      return unless record

      record['detail']['hex']
    end

    def fetch_icao_database_name
      page_string = URI.open(BASE_URL, &:read)

      return unless (db = page_string.match(/databaseFolder = "(db-\w+)"/))

      db[1]
    end

    def load_reg_icao
      content = load_reg_icao_cached

      return content if content

      url = "#{BASE_URL}/#{fetch_icao_database_name}/regIcao.js"
      JsonLoader.load(url).tap do |j|
        File.write(REG_ICAO_FILE, Oj.dump(j))
      end
    end

    def load_reg_icao_cached
      return unless File.exist?(REG_ICAO_FILE)

      if Time.now - File.mtime(REG_ICAO_FILE) < CACHE_TIME
        Oj.load(File.read(REG_ICAO_FILE))
      else
        File.delete(REG_ICAO_FILE)
        nil
      end
    end
  end
end
