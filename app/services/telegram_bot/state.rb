# frozen_string_literal: true

module TelegramBot
  class State
    def initialize
      @state = {}
    end

    def get(chat_id)
      @state[chat_id]
    end

    def set(chat_id, value)
      @state[chat_id] = value
    end

    def delete(chat_id)
      @state.delete(chat_id)
    end

    def purge
      @state = {}
    end
  end
end
