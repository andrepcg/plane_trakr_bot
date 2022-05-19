# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:alerts) do
      set_column_allow_null :registration
    end
  end
end
