# frozen_string_literal: true

Server.configure do |c|
  c.database.url       = ENV.fetch("DATABASE_URL") { "sqlite://development.rb" }
  c.telegram_bot_token = ENV.fetch("TELEGRAM_TOKEN")
end
