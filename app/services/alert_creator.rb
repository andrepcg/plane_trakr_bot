
class AlertCreator
  def self.create(reg_or_icao, message)
    new(reg_or_icao, message).call
  end

  def initialize(reg_or_icao, message)
    @reg_or_icao = reg_or_icao
    @message = message
  end

  def call
    Alert.create(
      icao: icao,
      registration: registration,
      created_at: Time.now,
      chat_id: @message.chat.id,
      chat_username: @message.from.username
    )
  end

  private

  def icao?
    @reg_or_icao.upcase == icao
  end

  def registration
    @registration ||= RegistrationHandler.registration(icao)&.upcase
  end

  def icao
    @icao ||= RegistrationHandler.icao_from_string(@reg_or_icao)&.upcase
  end
end