require "web3_api/moralis/client"
require "rails_helper"

RSpec.describe Web3Api::Moralis::Client do
  let(:client) { described_class.new }

  describe "#retrieve_tokens" do
    let(:wallet_address) { SecureRandom.hex }
    let(:chain) { "eth" }

    let(:request_path) { "#{described_class::BASE_URI}/#{wallet_address}/#{described_class::TOKENS_URI_PATH}?chain=#{chain}" }

    before do
      stub_request(:get, request_path)
      ENV["MORALIS_API_KEY"] = "123"
    end

    let(:expected_headers) do
      {
        "Content-Type": "application/json; charset=utf-8",
        "x-api-key": "123"
      }
    end

    it "makes a request to retrieve the wallet tokens" do
      client.retrieve_tokens(wallet_address: wallet_address, chain: chain)

      expect(
        a_request(:get, request_path)
          .with(headers: expected_headers)
      )
        .to have_been_made
        .once
    end
  end

  describe "#retrieve_nfts" do
    let(:wallet_address) { SecureRandom.hex }
    let(:chain) { "eth" }

    let(:request_path) { "#{described_class::BASE_URI}/#{wallet_address}/#{described_class::NFTS_URI_PATH}?chain=#{chain}" }

    before do
      stub_request(:get, request_path)
      ENV["MORALIS_API_KEY"] = "123"
    end

    let(:expected_headers) do
      {
        "Content-Type": "application/json; charset=utf-8",
        "x-api-key": "123"
      }
    end

    it "makes a request to retrieve the wallet nfts" do
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
