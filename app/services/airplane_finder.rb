# frozen_string_literal: true

require 'open-uri'
require 'oj'

class AirplaneFinder
  class IcaoNotFoundError < StandardError; end
  class TraceNotFoundError < StandardError; end

  # Value can be ICAO, Registration or Callsign
  def initialize(value)
    @value = value
    @details = infer_details(value)

    raise IcaoNotFoundError, 'ICAO could not be found' unless @details
  end

  def get_recent_trace
    url = "https://globe.adsbexchange.com/data/traces/#{icao[-2..]}/trace_recent_#{icao}.json"
    info = JsonLoader.load(url, 'Referer' => 'https://globe.adsbexchange.com')
    AirplaneInfo.build_from_trace(info)
  rescue OpenURI::HTTPError => e
    LOGGER.debug("Failed to get plane trace: #{e.message}")
    raise TraceNotFoundError, 'Could not find plane online'
  end

  attr_reader :value, :details

  delegate :icao, :registration, to: :details

  private

  def infer_details(value)
    AirplaneSimpleDetails.build_infer(value)
  end
end
