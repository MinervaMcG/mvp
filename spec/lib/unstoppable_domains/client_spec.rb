require "unstoppable_domains/client"
require "rails_helper"

RSpec.describe UnstoppableDomains::Client do
  let(:client) { described_class.new }

  describe "#get_address_domains" do
    let(:address) { "address" }
    let(:request_url) { "#{described_class::BASE_URI}/reverse/#{address}" }

    before do
      ENV["UNSTOPPABLE_DOMAINS_API_KEY"] = "api_key"

      stub_request(:get, request_url)
    end

    it "makes a request to retrieve the address domains" do
      client.get_address_domains(address: address)

      expect(
        a_request(:get, request_url)
          .with(
            headers: {
              Authorization: "Bearer api_key"
            }
          )
      )
        .to have_been_made
        .once
    end
  end
end
