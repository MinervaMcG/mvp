require "web3_api/celo_explorer/client"
require "rails_helper"

RSpec.describe Web3Api::CeloExplorer::Client do
  let(:client) { described_class.new }

  describe "#retrieve_tokens" do
    let(:wallet_address) { SecureRandom.hex }

    let(:request_path) { "https://celo.api?action=tokenlist&address=#{wallet_address}&module=account" }

    before do
      stub_request(:get, request_path)
      ENV["CELO_EXPLORER_BASE_URI"] = "https://celo.api"
    end

    let(:expected_headers) do
      {
        "Content-Type": "application/json",
        Accept: "application/json"
      }
    end

    it "makes a request to retrieve the wallet tokens" do
      client.retrieve_tokens(wallet_address: wallet_address)

      expect(
        a_request(:get, request_path)
          .with(headers: expected_headers)
      )
        .to have_been_made
        .once
    end
  end
end
