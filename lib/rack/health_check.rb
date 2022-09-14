require "json"

module Rack
  class HealthCheck
    def call(env)
      status = {
        redis: {
          connected: redis_connected
        },
        postgres: {
          connected: postgres_connected
        }
      }

      [200, {}, [JSON.generate(status)]]
    end

    protected

    def redis_connected
      redis.ping == "PONG"
    rescue
      false
    end

    def redis
      Redis.new(url: ENV["REDIS_URL"])
    end

    def postgres_connected
      return true if ApplicationRecord.connected?

      ApplicationRecord.establish_connection
      ApplicationRecord.connection
      ApplicationRecord.connected?
    rescue
      false
    end
  end
end
