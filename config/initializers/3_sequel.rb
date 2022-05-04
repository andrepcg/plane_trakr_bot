# frozen_string_literal: true

require 'sequel'
require 'sqlite3' if ENV['RUBY_ENV'] == 'development'
require 'pg'

Sequel.extension :migration

Sequel::Model.plugin :validation_helpers

DATABASE = Sequel.connect(Server.config.database.url)
DATABASE.extension :date_arithmetic
