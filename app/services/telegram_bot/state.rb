# frozen_string_literal: true

module TelegramBot
  class State
    STATE = {}.freeze

    def get(chat_id)
      STATE[chat_id]
    end

    def set(chat_id, value)
      STATE[chat_id] = value
    end

    def delete(chat_id)
      STATE.delete(chat_id)
    end
  end
end
