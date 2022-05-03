# frozen_string_literal: true

require 'sequel'
require 'sqlite3'

Sequel.extension :migration
Sequel::Model.plugin :validation_helpers

DATABASE = Sequel.connect(Server.config.database.url)
