require "faraday_middleware/aws_sigv4"

if Rails.env.production?
  Chewy.settings = {
    host: ENV["AWS_ELASTICSEARCH_URL"],
    port: 443, # 443 for https host
    transport_options: {
      headers: {content_type: "application/json"},
      proc: ->(f) do
        f.request :aws_sigv4,
          service: "es",
          region: ENV["AWS_ELASTICSEARCH_REGION"],
          access_key_id: ENV["AWS_ELASTICSEARCH_ACCESS_KEY_ID"],
          secret_access_key: ENV["AWS_ELASTICSEARCH_SECRET_ACCESS_KEY"]
      end
    }
  }
end

Chewy.settings = {host: "localhost:9200"} if Rails.env.development?
Chewy.settings = {host: "localhost:9250"} if Rails.env.test?

Chewy.root_strategy = :lazy_sidekiq
Chewy.request_strategy = :lazy_sidekiq
Chewy.console_strategy = :lazy_sidekiq
