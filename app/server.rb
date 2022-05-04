# frozen_string_literal: true

class Server
  extend Dry::Configurable

  setting :root
  setting :telegram_bot_token

  setting :database do
    setting :url
  end

  class << self
    include Initialization
  end
end
