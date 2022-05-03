# frozen_string_literal: true

require 'open-uri'
require 'oj'

class RegistrationHandler
  BASE_URL = "https://globe.adsbexchange.com"
  REG_ICAO_FILE = "reg_icao.json"

  class << self
    def load
      @REG_ICAO_CACHE = load_reg_icao
    end

    def registration(value)
      raise "Registration hasn't been loaded" unless @REG_ICAO_CACHE

      @REG_ICAO_CACHE.key(value)
    end

    def icao_from_string(value)
      raise "Registration hasn't been loaded" unless @REG_ICAO_CACHE

      @REG_ICAO_CACHE[value.upcase]&.upcase || value.upcase
    end

    private

    def load_json(url, options = {})
      res = URI.open(url, options, &:read)

      Oj.load(res)
    end

    def get_icao_database_name
      page_string = URI.open(BASE_URL, &:read)

      if db = page_string.match(/databaseFolder \= \"(db-\w+)\"/)
        db[1]
      end
    end

    def load_reg_icao
      content = load_reg_icao_cached

      return content if content

      url = "#{BASE_URL}/#{get_icao_database_name}/regIcao.js"
      load_json(url).tap do |j|
        File.write(REG_ICAO_FILE, Oj.dump(j))
      end
    end

    def load_reg_icao_cached
      return unless File.exists?(REG_ICAO_FILE)

      if Time.now - File.mtime(REG_ICAO_FILE) < 1.hour
        Oj.load(File.read(REG_ICAO_FILE))
      else
        File.delete(REG_ICAO_FILE)
        nil
      end
    end
  end
end