require 'dry-struct'

class AirplaneSimpleDetails < Dry::Struct
  transform_keys(&:to_sym)

  attribute :icao, Dry.Types::String
  attribute :registration, Dry.Types::String
  attribute :callsign, Dry.Types::String | Dry.Types::Nil

  def self.build_infer(value)
    icao = nil
    registration = nil
    callsign = nil

    if icao = RegistrationHandler.icao_from_registration(value)&.downcase
      registration = value
    elsif registration = RegistrationHandler.registration_from_icao(value)
      icao = value.downcase
    elsif registration = CallsignHandler.search(value)
      icao = RegistrationHandler.icao_from_registration(registration).downcase
      callsign = value
    end

    return unless icao

    new(icao: icao.upcase, registration: registration.upcase, callsign: callsign&.upcase)
  end
end
