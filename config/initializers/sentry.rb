# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']

  config.breadcrumbs_logger = [:sentry_logger]

  config.traces_sample_rate = 0.75
end
