# frozen_string_literal: true

require 'dry-struct'

module AdsbX
  class TraceItem < Dry::Struct
    transform_keys(&:to_sym)

    attribute :seconds_after_ts, Dry.Types::Coercible::Float
    attribute :lat, Dry.Types::Coercible::Float
    attribute :lng, Dry.Types::Coercible::Float
    attribute :altitude_ft, Dry.Types::Coercible::Float | Dry.Types::String | Dry.Types::Nil
    attribute :ground_speed_knots, Dry.Types::Coercible::Float | Dry.Types::Nil
    attribute :track_degrees_knots, Dry.Types::Coercible::Float | Dry.Types::Nil
    attribute :flags, Dry.Types::Integer.default(0)
    attribute :vertical_rate_fpm, Dry.Types::Coercible::Float | Dry.Types::Nil
    attribute :details, Dry.Types::Hash | Dry.Types::Nil
    attribute :source, Dry.Types::String | Dry.Types::Nil
    attribute :geomeetric_altitude, Dry.Types::Coercible::Float | Dry.Types::Nil
    attribute :geomeetric_vertical_rate, Dry.Types::Coercible::Float | Dry.Types::Nil
    attribute :airspeed, Dry.Types::Coercible::Float | Dry.Types::Nil
    attribute :roll_angle, Dry.Types::Coercible::Float | Dry.Types::Nil

    def self.build_from_trace(trace)
      new(
        seconds_after_ts: trace[0],
        lat: trace[1],
        lng: trace[2],
        altitude_ft: trace[3],
        ground_speed_knots: trace[4],
        track_degrees_knots: trace[5],
        flags: trace[6],
        vertical_rate_fpm: trace[7],
        details: trace[8],
        source: trace[9],
        geomeetric_altitude: trace[10],
        geomeetric_vertical_rate: trace[11],
        airspeed: trace[12],
        roll_angle: trace[13]
      )
    end

    def altitude_type
      altitude_geometric? ? :geometric : :barometric
    end

    def vertical_rate_type
      vertical_rate_geometric? ? :geometric : :barometric
    end

    def grounded?
      altitude_ft == 'ground'
    end

    def stale_position?
      (flags & 1).positive?
    end

    def new_leg?
      (flags & 2).positive?
    end

    def vertical_rate_geometric?
      (flags & 4).positive?
    end

    def altitude_geometric?
      (flags & 8).positive?
    end
  end
end
