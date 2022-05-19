# frozen_string_literal: true

require 'dry-struct'

class AirplaneSimpleDetails < Dry::Struct
  transform_keys(&:to_sym)

  attribute :icao, Dry.Types::String
  attribute :registration, Dry.Types::String | Dry.Types::Nil
  attribute :callsign, Dry.Types::String | Dry.Types::Nil

  def self.build_infer(value)
    icao = nil
    registration = nil
    callsign = nil

    if (icao = RegistrationHandler.icao_from_registration(value))
      registration = value
    elsif (registration = RegistrationHandler.registration_from_icao(value))
      icao = value
    elsif (registration = CallsignHandler.search(value))
      icao = RegistrationHandler.icao_from_registration(registration)
      callsign = value
    else
      begin
        AdsbX::Api.new.recent_trace(value)
        icao = value
      rescue AdsbX::TraceNotFoundError
      end
    end

    return unless icao

    new(icao: icao.upcase, registration: registration&.upcase, callsign: callsign&.upcase)
  end
end
