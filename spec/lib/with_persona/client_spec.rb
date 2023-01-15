require "with_persona/client"
require "rails_helper"

RSpec.describe WithPersona::Client do
  let(:client) { described_class.new }

  describe "#fetch_inquiry" do
    let(:inquiry_id) { "inquiry_id" }

    before do
      ENV["WITH_PERSONA_API_KEY"] = "client_id"

      stub_request(:get, "#{described_class::INQUIRY_URI}/#{inquiry_id}")
    end

    it "makes a request to fetch an inquiry" do
      client.fetch_inquiry(inquiry_id: inquiry_id)

      expect(
        a_request(:get, "#{described_class::INQUIRY_URI}/#{inquiry_id}")
          .with(headers: {
            Authorization: "Bearer client_id",
            "Content-Type": "application/vnd.api+json"
          })
      )
        .to have_been_made
        .once
    end
  end
end
