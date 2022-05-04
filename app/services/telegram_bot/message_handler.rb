# frozen_string_literal: true

module TelegramBot
  class MessageHandler
    WAITING_FOR_ID_CREATE = "waiting_for_id_create"
    WAITING_FOR_ID_DELETE = "waiting_for_id_delete"

    attr_reader :message
    attr_reader :bot
    attr_reader :user

    GREETING_MARKUP = Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'View alerts', callback_data: 'view_alerts'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Create alert', callback_data: 'create_alert'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Delete alert', callback_data: 'delete_alert')
      ]
    ).freeze

    def initialize(bot:, message:, state:)
      @bot = bot
      @message = message
      @state = state
      # @user = User.find_or_create_by(uid: message.from.id)
    end

    def respond
      chat_state = @state.get(chat_id)

      on_text(/^\/(start|help)/) do
        answer_with_greeting_message
      end

      on_text(/^\/create_alert ([a-z\-0-9]+)/i) do |id|
        create_alert(id)
      end

      on_text(/^\/create_alert$/) do
        @state.set(chat_id, WAITING_FOR_ID_CREATE)
        answer_with_message("Enter a ICAO, Registration ID or Callsign")
      end

      on_text(/^([a-z\-0-9]+)/i) do |id|
        return unless chat_state == WAITING_FOR_ID_CREATE

        create_alert(id)
        @state.delete(chat_id)
      end

      on_text(/^\/view_alerts$/) do |id|
        view_alerts
      end

      # on_text(/^[^\/].*/) do |id|
      #   return unless chat_state == WAITING_FOR_ID_DELETE
      # end

      on_callback(/^view_alerts$/) do
        view_alerts
      end

      on_callback(/^delete_alert$/) do
        delete_alert_message
      end

      on_callback(/delete_(\d+)/) do |id|
        delete_alert(id)
      end

      on_callback(/^create_alert$/) do
        @state.set(chat_id, WAITING_FOR_ID_CREATE)
        answer_with_message("Enter a ICAO, Registration ID or Callsign")
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

    def on_callback(regex, &block)
      return if message.is_a?(Telegram::Bot::Types::Message)

      bot.api.answer_callback_query(callback_query_id: message.id)

      regex =~ message.data

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

    def answer_with_greeting_message
      answer_with_message(
        "Welcome to PlaneTrackr! You'll be able to set alerts for planes by registration " \
          "or ICAO number and when they start flying we'll send you an alert.",
        markup: GREETING_MARKUP
      )
    end

    def delete_alert_message
      kb = user_alerts.map.with_index do |alert, i|
        name = "#{i + 1} - #{alert.name}"
        Telegram::Bot::Types::InlineKeyboardButton.new(text: name, callback_data: "delete_#{alert.id}")
      end

      answer_with_message(
        "Which alert do you want to delete?",
        markup: Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      )
    end

    def delete_alert(id)
      alert = user_alerts.first(id: id)
      return unless alert

      alert.destroy
      answer_with_message("Alert #{alert.name} deleted")
    end

    def view_alerts
      alerts = user_alerts.map { |alert| alert.name }

      if alerts.size > 0
        answer_with_message("Current alerts:\n#{alerts.join("\n")}")
      else
        answer_with_message("No alerts")
      end
    end

    def create_alert(value)
      alert = Alerts::Creator.create(value, message)
      answer_with_message("Alert for #{alert.registration} (#{alert.icao}) created!")
    rescue AirplaneFinder::IcaoNotFoundError => e
      answer_with_message("Could not find any plane (ICAO, Registration, Callsign) for '#{value}'")
    end

    def answer_with_message(text, markup: nil)
      if markup
        bot.api.send_message(chat_id: chat_id, text: text, reply_markup: markup)
      else
        bot.api.send_message(chat_id: chat_id, text: text)
      end
    end

    def user_alerts
      ::Alert.where(chat_id: chat_id)
    end

    def chat_id
      id = case message
           when Telegram::Bot::Types::CallbackQuery
             message.from.id
           when Telegram::Bot::Types::Message
             message.chat.id
           end
      id.to_s
    end
  end
end
