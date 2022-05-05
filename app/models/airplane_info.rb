# frozen_string_literal: true

require 'dry-struct'

class AirplaneInfo < Dry::Struct
  transform_keys(&:to_sym)

  attribute :icao, Dry.Types::String
  attribute :r, Dry.Types::String
  attribute :t, Dry.Types::String
  attribute :desc, Dry.Types::String
  attribute :timestamp, Dry.Types::Coercible::Float # last timestamp
  attribute :trace, Dry.Types::Array.of(AirplaneTrace)

  def self.build_from_trace(trace)
    t = trace['trace'].map { |tr| AirplaneTrace.build_from_trace(tr) }
    new(**trace.merge('trace' => t))
  end

  def last_location
    last_trace = trace.last
    [last_trace.lat, last_trace.lng]
  end

  def start_time
    Time.at(timestamp.to_i).to_datetime
  end

  def grounded?
    trace.last.altitude_ft == 'ground'
  end

  def last_data_received
    Time.at(timestamp + trace.last.seconds_after_ts).to_datetime
  end
end
