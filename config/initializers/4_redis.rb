# frozen_string_literal: true

require 'redis'

# REDIS = Redis.new

REDIS_CACHE = if ENV['REDIS_URL']
                ActiveSupport::Cache::RedisCacheStore.new(url: ENV['REDIS_URL'])
              else
                ActiveSupport::Cache::NullStore.new
              end
