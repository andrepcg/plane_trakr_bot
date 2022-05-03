# frozen_string_literal: true

class Alert < Sequel::Model
  CHECK_INTERVAL = 5.minutes

  def validate
    super
    validates_presence [:chat_id, :icao]
    validates_unique :chat_id, :icao
  end
end
