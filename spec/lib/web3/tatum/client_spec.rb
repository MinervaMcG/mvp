require "web3/tatum/client"
require "rails_helper"

RSpec.describe Web3::Tatum::Client do
  let(:client) { described_class.new }

  describe "#retrieve_tokens" do
    let(:wallet_address) { SecureRandom.hex }
    let(:chain) { "CELO" }

    let(:request_path) { "#{described_class::BASE_URI}/nft/address/balance/#{chain}/#{wallet_address}" }

    before do
      stub_request(:get, request_path)
      ENV["TATUM_API_KEY"] = "123"
    end

    let(:expected_headers) do
      {
        "Content-Type": "application/json",
        Accept: "application/json",
        "x-api-key": "123"
      }
    end

    it "makes a request to retrieve the wallet tokens" do
      client.retrieve_nfts(wallet_address: wallet_address, chain: chain)

      expect(
        a_request(:get, request_path)
          .with(headers: expected_headers)
      )
        .to have_been_made
        .once
    end
  end
end
