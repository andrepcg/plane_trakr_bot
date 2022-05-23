# frozen_string_literal: true

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
    AdsbX::Api.new.recent_trace(icao)
  rescue AdsbX::TraceNotFoundError => e
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
