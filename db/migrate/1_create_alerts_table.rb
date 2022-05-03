# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:alerts) do
      primary_key :id
      String :chat_id, null: false, index: true
      String :chat_username
      String :icao, null: false
      String :registration
      DateTime :created_at, null: false
      DateTime :last_check_at
      Integer :alerts_sent, default: 0
      unique [:chat_id, :icao]
    end
  end
end
