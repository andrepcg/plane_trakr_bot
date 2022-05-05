# frozen_string_literal: true

Sequel.migration do
  change do
    add_column :alerts, :updated_at, DateTime
  end
end
