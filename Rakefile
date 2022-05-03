# frozen_string_literal: true

ENV["RUBY_ENV"] ||= "development"

require "bundler"
Bundler.require(:default, ENV["RUBY_ENV"])

require "rake"
Rake.add_rakelib "lib/tasks"

ENV["RUN_BOT"] = "false"

task :environment do
  require_relative "app"
end
