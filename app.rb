# frozen_string_literal: true

require "rubygems"

ENV["RUBY_ENV"] ||= "development"

require "bundler"
Bundler.require(:default, ENV["RUBY_ENV"])

require "active_support"
require "active_support/time"

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/app")
loader.push_dir("#{__dir__}/app/models")
loader.push_dir("#{__dir__}/app/services")
loader.push_dir("#{__dir__}/lib")
loader.setup

Server.initialize!
