# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:alerts) do
      primary_key :id
      String :chat_id, null: false, index: true
      String :chat_username
      String :icao, null: false
      String :registration, null: false
      DateTime :created_at, null: false
      DateTime :last_check_at
      String :last_check_details, default: 'not_found'
      DateTime :last_alert_sent_at
      Integer :alerts_sent, default: 0
      unique %i[chat_id icao]
    end
  end
end
