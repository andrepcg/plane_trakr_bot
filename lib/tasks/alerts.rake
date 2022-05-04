# frozen_string_literal: true

namespace :alerts do
  desc 'Process existing alerts and sends messages'
  task process: :environment do
    Alerts::Checker.call
  end
end
