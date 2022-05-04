module TelegramBot
  class State
    STATE = {}

    def get(chat_id)
      STATE[chat_id]
    end

    def set(chat_id, s)
      STATE[chat_id] = s
    end

    def delete(chat_id)
      STATE.delete(chat_id)
    end
  end
end
