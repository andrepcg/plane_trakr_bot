require 'dry-struct'

class AirplaneInfo < Dry::Struct
  transform_keys(&:to_sym)

  attribute :icao, Dry.Types::String
  attribute :r, Dry.Types::String
  attribute :t, Dry.Types::String
  attribute :desc, Dry.Types::String
  attribute :timestamp, Dry.Types::Coercible::Float
  attribute :trace, Dry.Types::Array.of(AirplaneTrace)

  def self.build_from_trace(trace)
    t = trace["trace"].map { |t| AirplaneTrace.build_from_trace(t) }
    new(**trace.merge("trace" => t))
  end

  def last_location
    last_trace = trace.last
    [last_trace.lat, last_trace.lng]
  end

  def start_time
    Time.at(timestamp.to_i).to_datetime
  end

  def grounded?
    trace.last.altitude_ft == "ground"
  end
end