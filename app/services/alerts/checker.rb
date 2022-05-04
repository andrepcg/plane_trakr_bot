
module Alerts
  class Checker
    class << self
      def call
        bot = Bot.new.client

        alerts.paged_each do |alert|
          Processor.call(alert, bot)
        end
      end

      def alerts
        Alert.with_check_available
      end
    end
  end
end
