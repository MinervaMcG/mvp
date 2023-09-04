require "rails_helper"

RSpec.describe "Persona Webhooks", type: :request do
  describe "#create" do
    subject(:persona_webhook_request) { post(external_persona_webhooks_path(params: params), headers: headers) }

    let(:params) do
      JSON.parse(file_fixture("persona_webhook_verification_created_body.json").read)
    end

    let(:headers) do
      {
        "Persona-Signature" => "t=24455665656,v1=valid!"
      }
    end

    before do
      ENV["WITH_PERSONA_WEBHOOK_SECRET"] = "secret"
      allow(OpenSSL::HMAC).to receive(:hexdigest).and_return("valid!")
    end

    it "returns a successful response" do
      persona_webhook_request

      expect(response).to have_http_status(:ok)
    end

    it "starts a job to take care of the information received" do
      persona_webhook_request

      expect(PersonaWebhookReceivedJob).to have_been_enqueued
    end

    context "when the request signature is invalid" do
      before do
        allow(OpenSSL::HMAC).to receive(:hexdigest).and_return("invalid!")
      end

      it "returns an unauthorized response" do
        persona_webhook_request

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
