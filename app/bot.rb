require 'telegram/bot'

class Bot
  def run
    client do |bot|
      @bot = bot

      LOGGER.debug("Telegram bot now listening")
      bot.listen { |m| on_message(m) }
    end
  end

  private

  attr_reader :bot

  def on_message(message)
    LOGGER.debug "@#{message.from.username} (chat_id: #{chat_id(message)}): #{text(message)}"
    TelegramBot::MessageHandler.new(bot: bot, message: message).respond
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

  def client(&block)
    Telegram::Bot::Client.run(Server.config.telegram_bot_token, &block)
  end
end
