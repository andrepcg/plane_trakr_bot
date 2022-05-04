require 'telegram/bot'

class Bot
  def run
    client.run do |bot|
      @bot = bot

      LOGGER.debug("Telegram bot now listening")
      bot.listen { |m| on_message(m) }
    end
  end

  def client
    t = Server.config.telegram_bot_token
    raise "Set your telegram bot token" unless t.present?
    Telegram::Bot::Client.new(t)
  end

  private

  attr_reader :bot

  def on_message(message)
    LOGGER.debug "@#{message.from.username} (chat_id: #{chat_id(message)}): #{text(message)} - #{message.class}"
    TelegramBot::MessageHandler.new(bot: bot, message: message, state: state).respond
  end

  def text(message)
    case message
    when Telegram::Bot::Types::CallbackQuery
      message.data
    when Telegram::Bot::Types::Message
      message.text
    end
  end

  def chat_id(message)
    case message
    when Telegram::Bot::Types::CallbackQuery
      message.from.id
    when Telegram::Bot::Types::Message
      message.chat.id
    end
  end

  def state
    @state ||= TelegramBot::State.new
  end
end
