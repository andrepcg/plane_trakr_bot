# frozen_string_literal: true

require_relative "app"

# Server.run
Bot.new.run if ENV["RUN_BOT"] == "true"
