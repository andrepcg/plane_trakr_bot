# frozen_string_literal: true

class Alert < Sequel::Model
  CHECK_INTERVAL = 9.minutes

  dataset_module do
    def with_check_available
      add = Sequel.date_add(:last_check_at, Alert::CHECK_INTERVAL)
      where(last_check_at: nil).or(add <= Sequel::CURRENT_TIMESTAMP)
    end
  end

  def validate
    super
    validates_presence %i[chat_id icao registration]
    validates_unique %i[chat_id icao]
  end

  def name
    "#{registration} (ICAO: #{icao})"
  end

  def increment_alerts!
    update(alerts_sent: Sequel.expr(1) + :alerts_sent)
  end
end
