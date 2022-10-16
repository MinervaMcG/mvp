require "faraday_middleware/aws_sigv4"

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
