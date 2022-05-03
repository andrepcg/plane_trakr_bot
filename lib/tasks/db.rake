# frozen_string_literal: true

require_relative "../migration"

namespace :db do
  desc 'Prints current schema version'
  task version: :environment do
    puts "Schema Version: #{Migration.new.version}"
  end

  desc 'Perform migration up to latest migration available'
  task migrate: :environment do
    Migration.new.migrate
    Rake::Task['db:version'].execute
  end

  desc 'Perform rollback to specified target or full rollback as default'
  task rollback: :environment do
    Migration.new.rollback(0)
    Rake::Task['db:version'].execute
  end

  desc 'Perform migration reset (full rollback and migration)'
  task reset: :environment do
    Migration.new.reset
    Rake::Task['db:version'].execute
  end
end

namespace :g do
  desc "generate migration"
  task migration: :environment do
    Migration.new.generate_migration(ARGV[1])
  end
end
