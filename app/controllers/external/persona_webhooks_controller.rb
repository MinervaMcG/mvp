class External::PersonaWebhooksController < ApplicationController
  VALID_IP_ADDRESSES = [
    "35.232.44.140",
    "34.69.131.123",
    "34.67.4.225"
  ]

  def create
    return render json: {message: "Invalid IP address"}, status: :unauthorized unless valid_ip?
    return render json: {message: "Invalid Signature address"}, status: :unauthorized unless valid_signature?

    PersonaWebhookReceivedJob.perform_later(params: webhook_params.to_h)

    head :ok
  end

  private

  def valid_ip?
    VALID_IP_ADDRESSES.include?(request.remote_ip)
  end

  def valid_signature?
    t, v1 = request.headers["HTTP_PERSONA_SIGNATURE"].split(",").map { |value| value.split("=").second }
    computed_digest = OpenSSL::HMAC.hexdigest("SHA256", ENV["WITH_PERSONA_WEBHOOK_SECRET"], "#{t}.#{request.body.read}")

    v1 == computed_digest
  end

  def webhook_params
    params.require(:data).permit!
  end
end
