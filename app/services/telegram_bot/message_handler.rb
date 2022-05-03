# frozen_string_literal: true

module TelegramBot
  class MessageHandler
    attr_reader :message
    attr_reader :bot
    attr_reader :user

    GREETING_MARKUP = Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'View alerts', callback_data: 'view_alerts'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Create alert', callback_data: 'create_alert')
      ]
    ).freeze

    def initialize(bot:, message:)
      @bot = bot
      @message = message
      # @user = User.find_or_create_by(uid: message.from.id)
    end

    def respond
      on_text(/^\/start/) do
        answer_with_greeting_message
      end

      on_text(/^\/help/) do
        answer_with_help_message
      end

      on_text(/^\/create_alert ([a-z\-0-9]+)/i) do |id|
        create_alert(id)
      end

      on_callback(/view_alerts/) do
        view_alerts
      end

      on_callback(/create_alert/) do
        answer_with_message("Send /create_alert <icao|registration>")
      end
    end

    private

    def on_text(regex, &block)
      return if message.is_a?(Telegram::Bot::Types::CallbackQuery)

      regex =~ message.text

      if $~
        case block.arity
        when 0
          yield
        when 1
          yield $1
        when 2
          yield $1, $2
        end
      end
    end

    def on_callback(regex)
      return if message.is_a?(Telegram::Bot::Types::Message)

      yield if regex =~ message.data
    end

    def answer_with_greeting_message
      answer_with_message(
        "Welcome to PlaneTrackr! You'll be able to set alerts for planes by registration " \
          "or ICAO number and when they start flying we'll send you an alert.",
        markup: GREETING_MARKUP
      )
    end

    def view_alerts
      alerts = ::Alert.where(chat_id: chat_id).map do |alert|
        "#{alert.icao} (#{alert.registration})"
      end

      if alerts.size > 0
        answer_with_message("Current alerts:\n#{alerts.join("\n")}")
      else
        answer_with_message("No alerts")
      end
    end

    def create_alert(value)
      alert = AlertCreator.create(value, message)
      answer_with_message("Alert for #{alert.registration} (#{alert.icao}) created!")
    rescue StandardError => e
    end

    def answer_with_help_message
      answer_with_message()
    end

    def answer_with_message(text, markup: nil)
      if markup
        bot.api.send_message(chat_id: chat_id, text: text, reply_markup: markup)
      else
        bot.api.send_message(chat_id: chat_id, text: text)
      end
    end

    def chat_id
      case message
      when Telegram::Bot::Types::CallbackQuery
        message.from.id
      when Telegram::Bot::Types::Message
        message.chat.id
      end
    end
  end
end
