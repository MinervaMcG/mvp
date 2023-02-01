require "web3_api/moralis/client"
require "web3_api/celo_explorer/client"
require "web3_api/gnosis_chain_explorer/client"
require "web3_api/tatum/client"
require "web3_api/api_proxy"
require "rails_helper"

RSpec.shared_examples "a moralis client get tokens request" do
  let(:client_class) { Web3Api::Moralis::Client }
  let(:client) { instance_double(client_class) }

  before do
    allow(client_class).to receive(:new).and_return(client)
    allow(client).to receive(:retrieve_tokens).and_return(response)
  end

  let(:response) do
    OpenStruct.new(
      success?: response_success,
      body: file_fixture("moralis_get_tokens_response.json").read
    )
  end
  let(:response_success) { true }

  it "initializes and calls the moralis client with the correct arguments" do
    request

    expect(client_class).to have_received(:new)
    expect(client).to have_received(:retrieve_tokens).with(
      wallet_address: wallet_address,
      chain: chain
    )
  end

  it "returns a json array with the tokens" do
    expect(request).to eq(
      [
        {
          address: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
          name: "Wrapped Ether",
          symbol: "WETH",
          logo: "https://cdn.moralis.io/eth/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2.png",
          thumbnail: "https://cdn.moralis.io/eth/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2_thumb.png",
          decimals: 18,
          balance: "50000000000000000"
        },
        {
          address: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
          name: "USD Coin",
          symbol: "USDC",
          logo: "https://cdn.moralis.io/eth/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.png",
          thumbnail: "https://cdn.moralis.io/eth/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48_thumb.png",
          decimals: 6,
          balance: "100000"
        },
        {
          address: "0xc18360217d8f7ab5e7c516566761ea12ce7f9d72",
          name: "Ethereum Name Service",
          symbol: "ENS",
          logo: nil,
          thumbnail: nil,
          decimals: 18,
          balance: "180000000000000000000"
        }
      ]
    )
  end

  context "when the request is not successful" do
    let(:response_success) { false }

    it "raises an api client error" do
      expect { request }.to raise_error(described_class::ApiClientRequestError)
    end
  end
end

RSpec.shared_examples "a celo explorer client get tokens request" do
  let(:client_class) { Web3Api::CeloExplorer::Client }
  let(:client) { instance_double(client_class) }

  before do
    allow(client_class).to receive(:new).and_return(client)
    allow(client).to receive(:retrieve_tokens).and_return(response)
  end

  let(:response) do
    OpenStruct.new(
      success?: response_success,
      body: file_fixture("celo_explorer_get_tokens_response.json").read
    )
  end
  let(:response_success) { true }

  it "initializes and calls the moralis client with the correct arguments" do
    request

    expect(client_class).to have_received(:new)
    expect(client).to have_received(:retrieve_tokens).with(
      wallet_address: wallet_address
    )
  end

  it "returns a json array with the tokens" do
    expect(request).to eq(
      [
        {
          balance: "200000000000000000000",
          address: "0x4c66010e91409589de79b0d67f078c87e01f4d96",
          decimals: "18",
          name: "caelin",
          symbol: "CAELIN",
          logo: nil,
          thumbnail: nil
        },
        {
          balance: "427124874055627212581",
          address: "0x00be915b9dcf56a3cbe739d9b9c202ca692409ec",
          decimals: "18",
          name: "Ubeswap",
          symbol: "UBE",
          logo: nil,
          thumbnail: nil
        },
        {
          balance: "100000000000000000000",
          address: "0x9d65cb7b629c16c939fcc2c731ad22a212704800",
          decimals: "18",
          name: "hustleelio",
          symbol: "ELI",
          logo: nil,
          thumbnail: nil
        }
      ]
    )
  end

  context "when the request is not successful" do
    let(:response_success) { false }

    it "raises an api client error" do
      expect { request }.to raise_error(described_class::ApiClientRequestError)
    end
  end
end

RSpec.shared_examples "a moralis client get nfts request" do
  let(:client_class) { Web3Api::Moralis::Client }
  let(:client) { instance_double(client_class) }

  before do
    allow(client_class).to receive(:new).and_return(client)
    allow(client).to receive(:retrieve_wallet_nfts).and_return(response)
  end

  let(:response) do
    OpenStruct.new(
      success?: response_success,
      body: file_fixture("moralis_get_nfts_response.json").read
    )
  end
  let(:response_success) { true }

  it "initializes and calls the moralis client with the correct arguments" do
    request

    expect(client_class).to have_received(:new)
    expect(client).to have_received(:retrieve_wallet_nfts).with(
      wallet_address: wallet_address,
      chain: formatted_chain
    )
  end

  it "returns a json array with the nfts" do
    expect(request).to eq(
      [
        {
          address: "0x951416cb5a9c5379ae696acb07cb8e25aefad370",
          token_id: "2919",
          amount: "1",
          name: "Crypto Nomads Club",
          symbol: "CNC",
          token_uri: "https://ipfs.moralis.io:2053/ipfs/QmRgvuYv5Y4qjQfXz7KshzQpSne1kM5dP4jAWuFyyTzZGH/LISBON.json",
          metadata: nil
        },
        {
          address: "0x7ffd8c64587026bf1a2c54bc77fa7d74f87d3338",
          token_id: "122",
          amount: "1",
          name: "MusicFund",
          symbol: "MUSICFUND",
          token_uri: "https://musicfund-backend.herokuapp.com/nfts/placeholders/122",
          metadata: nil
        },
        {
          address: "0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85",
          token_id: "32543023788032106523154235704456267944048946694964671196751682842436162158497",
          amount: "1",
          name: "Ethereum Name Service",
          symbol: "ENS",
          token_uri: "https://metadata.ens.domains/mainnet/0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85/32543023788032106523154235704456267944048946694964671196751682842436162158497",
          metadata: {
            "is_normalized" => true,
            "name" => "asd.eth",
            "description" => "asd.eth, an ENS name.",
            "attributes" => [{"trait_type" => "Created Date", "display_type" => "date", "value" => nil},
              {"trait_type" => "Length", "display_type" => "number", "value" => 6},
              {"trait_type" => "Registration Date", "display_type" => "date", "value" => 1631282170000},
              {"trait_type" => "Expiration Date", "display_type" => "date", "value" => 1946851690000}],
            "name_length" => 6,
            "url" => "https://app.ens.domains/name/asd.eth",
            "version" => 0,
            "background_image" => "https://metadata.ens.domains/mainnet/avatar/asd.eth",
            "image_url" => "https://metadata.ens.domains/mainnet/0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85/0x47f2b2dff721ac5f3ee7a3cd1703223fcc36a9ad9b03b2654ecaf94a8cddffa1/image"
          }
        },
        {
          address: "0x9213256fe89fa0428e8546910a8d78180dbbdc38",
          token_id: "903",
          amount: "1",
          name: "Storyteller Card",
          symbol: "FILMMAKER",
          token_uri: nil,
          metadata: nil
        }
      ]
    )
  end

  context "when the request is not successful" do
    let(:response_success) { false }

    it "raises an api client error" do
      expect { request }.to raise_error(described_class::ApiClientRequestError)
    end
  end
end

RSpec.shared_examples "a tatum client get nfts request" do |expected_chain|
  let(:client_class) { Web3Api::Tatum::Client }
  let(:client) { instance_double(client_class) }

  before do
    allow(client_class).to receive(:new).and_return(client)
    allow(client).to receive(:retrieve_nfts).and_return(response)
  end

  let(:response) do
    OpenStruct.new(
      status: response_status,
      success?: response_success,
      body: file_fixture("tatum_get_nfts_response.json").read
    )
  end
  let(:response_status) { 200 }
  let(:response_success) { true }

  it "initializes and calls the moralis client with the correct arguments" do
    request

    expect(client_class).to have_received(:new)
    expect(client).to have_received(:retrieve_nfts).with(
      wallet_address: wallet_address,
      chain: expected_chain
    )
  end

  it "returns a json array with the nfts" do
    expect(request).to eq(
      [
        {
          address: "0x1ecd77075f7504ba849d47dce4cdc9695f1fe942",
          token_id: "627",
          amount: 1,
          name: "CeloApesKingdom #627",
          symbol: "CeloApesKingdom #627",
          token_uri: "https://ipfs.io/ipfs/bafybeih6g4g7ul4s3l2b6axygpf7s6fkpwhd6e5elgl2t7gmdwlc6lsmjq/metadata/627.json",
          metadata: {
            "dna" => "030000070000001200000000",
            "edition" => 627,
            "attributes" => [
              {
                "trait_type" => "Species",
                "value" => "Blue Citizen Ape"
              },
              {
                "trait_type" => "Background",
                "value" => "Light Purple"
              },
              {
                "trait_type" => "Head",
                "value" => "Bunny Ear"
              }
            ],
            "name" => "CeloApesKingdom #627",
            "date" => 1635923686814,
            "description" => "Celo Apes are native Apes NFT on the Celo Blockchain. All the NFT holders will be part of the Ape Kingdom. Only 10000 Apes will be minted with new and unique traits!",
            "image" => "ipfs://bafybeiasnbk7bztvmytiqf2a5aw5jmivvnxhrdwtp72ihbpjrlh33g32ee/apes/627.png"
          }
        },
        {
          address: "0x1ecd77075f7504ba849d47dce4cdc9695f1fe942",
          token_id: "628",
          amount: 1,
          name: "CeloApesKingdom #628",
          symbol: "CeloApesKingdom #628",
          token_uri: "https://ipfs.io/ipfs/bafybeih6g4g7ul4s3l2b6axygpf7s6fkpwhd6e5elgl2t7gmdwlc6lsmjq/metadata/628.json",
          metadata: {
            "dna" => "120001080003030010000002",
            "edition" => 628,
            "attributes" => [
              {
                "trait_type" => "Species",
                "value" => "Pink Ape"
              },
              {
                "trait_type" => "Eyes",
                "value" => "BloodShot"
              },
              {
                "trait_type" => "Background",
                "value" => "Purple"
              },
              {
                "trait_type" => "Glasses",
                "value" => "Modern Glasses"
              },
              {
                "trait_type" => "Clothes",
                "value" => "Dark Half Sleve"
              },
              {
                "trait_type" => "Beams",
                "value" => "Straight Yellow"
              },
              {
                "trait_type" => "Mouth Props",
                "value" => "Cigarette"
              }
            ],
            "name" => "CeloApesKingdom #628",
            "date" => 1635923686814,
            "description" => "Celo Apes are native Apes NFT on the Celo Blockchain. All the NFT holders will be part of the Ape Kingdom. Only 10000 Apes will be minted with new and unique traits!",
            "image" => "ipfs://bafybeiasnbk7bztvmytiqf2a5aw5jmivvnxhrdwtp72ihbpjrlh33g32ee/apes/628.png"
          }
        },
        {
          address: "0xdf204de57532242700d988422996e9ced7aba4cb",
          token_id: "80933583340990441618616735003812808159743996514813210066433383033497073517002",
          amount: 1,
          name: nil,
          symbol: nil,
          token_uri: nil,
          metadata: nil
        }
      ]
    )
  end

  context "when the request is not successful" do
    let(:response_success) { false }

    it "raises an api client error" do
      expect { request }.to raise_error(described_class::ApiClientRequestError)
    end

    context "when the status is forbidden" do
      let(:response_status) { 403 }

      it "does not raise an api client error" do
        expect { request }.not_to raise_error
      end

      it "returns an empty json array" do
        expect(request).to eq([])
      end
    end
  end
end

RSpec.shared_examples "a celo explorer client get nfts request" do
  let(:client_class) { Web3Api::CeloExplorer::Client }
  let(:client) { instance_double(client_class) }

  before do
    allow(client_class).to receive(:new).and_return(client)
    allow(client).to receive(:retrieve_tokens).and_return(response)
  end

  let(:response) do
    OpenStruct.new(
      success?: response_success,
      body: file_fixture("celo_explorer_get_tokens_response.json").read
    )
  end
  let(:response_success) { true }

  it "initializes and calls the moralis client with the correct arguments" do
    request

    expect(client_class).to have_received(:new)
    expect(client).to have_received(:retrieve_tokens).with(
      wallet_address: wallet_address
    )
  end

  it "returns a json array with the nfts" do
    expect(request).to eq(
      [
        {
          amount: "1",
          address: "0x1427626c85b96a9288f8f420530c11e4e1efde9f",
          name: "Talent Protocol Community Member",
          symbol: "TALMEMBERS1",
          metadata: nil,
          token_uri: nil,
          token_id: nil
        },
        {
          amount: "1",
          address: "0x68d8077a0f8f653fd811063d796ceeecd0f8d746",
          name: "Talent Protocol Community User",
          symbol: "TALUSERS1",
          metadata: nil,
          token_uri: nil,
          token_id: nil
        }
      ]
    )
  end

  context "when the request is not successful" do
    let(:response_success) { false }

    it "raises an api client error" do
      expect { request }.to raise_error(described_class::ApiClientRequestError)
    end
  end
end

RSpec.shared_examples "a celo explorer client get transactions count request" do
  let(:client_class) { Web3Api::CeloExplorer::Client }
  let(:client) { instance_double(client_class) }

  before do
    allow(client_class).to receive(:new).and_return(client)
    allow(client).to receive(:retrieve_transactions).and_return(response)
  end

  let(:response) do
    OpenStruct.new(
      success?: response_success,
      body: file_fixture("celo_explorer_get_transactions_response.json").read
    )
  end
  let(:response_success) { true }

  it "initializes and calls the moralis client with the correct arguments" do
    request

    expect(client_class).to have_received(:new)
    expect(client).to have_received(:retrieve_transactions).with(
      address: wallet_address,
      start_timestamp: start_timestamp
    )
  end

  it "returns the count of transactions" do
    expect(request).to eq(2)
  end

  context "when the request is not successful" do
    let(:response_success) { false }

    it "raises an api client error" do
      expect { request }.to raise_error(described_class::ApiClientRequestError)
    end
  end
end

RSpec.shared_examples "a moralis client get transactions count request" do
  let(:client_class) { Web3Api::Moralis::Client }
  let(:client) { instance_double(client_class) }

  before do
    allow(client_class).to receive(:new).and_return(client)
    allow(client).to receive(:retrieve_transactions).and_return(response)
  end

  let(:response) do
    OpenStruct.new(
      success?: response_success,
      body: file_fixture("moralis_get_transactions_response.json").read
    )
  end
  let(:response_success) { true }

  it "initializes and calls the moralis client with the correct arguments" do
    request

    expect(client_class).to have_received(:new)
    expect(client).to have_received(:retrieve_transactions).with(
      address: wallet_address,
      start_timestamp: start_timestamp,
      chain: formatted_chain
    )
  end

  it "returns a the total number of transactions" do
    expect(request).to eq(1000)
  end

  context "when the request is not successful" do
    let(:response_success) { false }

    it "raises an api client error" do
      expect { request }.to raise_error(described_class::ApiClientRequestError)
    end
  end
end

RSpec.shared_examples "a gnosis chain explorer client get tokens request" do
  let(:client_class) { Web3Api::GnosisChainExplorer::Client }
  let(:client) { instance_double(client_class) }

  before do
    allow(client_class).to receive(:new).and_return(client)
    allow(client).to receive(:retrieve_tokens).and_return(response)
  end

  let(:response) do
    OpenStruct.new(
      success?: response_success,
      body: body
    )
  end
  let(:response_success) { true }
  let(:body) { file_fixture("gnosis_chain_get_poaps_response.json").read }

  it "initializes and calls the moralis client with the correct arguments" do
    request

    expect(client_class).to have_received(:new)
    expect(client).to have_received(:retrieve_tokens).with(
      wallet_address: wallet_address
    )
  end

  it "returns a json array with the nfts" do
    expect(request).to match_array(
      [
        {
          address: "0x22c1f6050e56d2876009903609a2cc3fef83b415",
          token_id: "5096568"
        },
        {
          address: "0x22c1f6050e56d2876009903609a2cc3fef83b415",
          token_id: "4826386"
        },
        {
          address: "0x22c1f6050e56d2876009903609a2cc3fef83b415",
          token_id: "4618978"
        }
      ]
    )
  end

  context "when the request is not successful" do
    let(:response_success) { false }

    it "raises an api client error" do
      expect { request }.to raise_error(described_class::ApiClientRequestError)
    end
  end
end

RSpec.shared_examples "an unsupported chain request" do
  it "raises an unsupported chain error" do
    expect { request }.to raise_error(described_class::UnsupportedChainError)
  end
end

RSpec.describe Web3Api::ApiProxy do
  let(:wallet_address) { SecureRandom.hex }
  let(:api_proxy) { described_class.new }
  let(:start_timestamp) { Time.now.to_i }

  describe "#retrieve_tokens" do
    subject(:request) { api_proxy.retrieve_tokens(wallet_address: wallet_address, chain: chain) }

    context "when the chain is eth" do
      let(:chain) { "eth" }

      it_behaves_like "a moralis client get tokens request"
    end

    context "when the chain is polygon" do
      let(:chain) { "polygon" }

      it_behaves_like "a moralis client get tokens request"
    end

    context "when the chain is celo" do
      let(:chain) { "celo" }

      it_behaves_like "a celo explorer client get tokens request"
    end

    context "when the chain is not yet supported" do
      let(:chain) { "bsc" }

      it_behaves_like "an unsupported chain request"
    end
  end

  describe "#retrieve_nfts" do
    subject(:request) { api_proxy.retrieve_nfts(wallet_address: wallet_address, chain: chain) }

    context "when the chain matches ethereum network" do
      context "when the chain is eth" do
        let(:chain) { "eth" }
        let(:formatted_chain) { "eth" }

        it_behaves_like "a moralis client get nfts request"
      end

      context "when the chain is 1" do
        let(:chain) { 1 }
        let(:formatted_chain) { "0x1" }

        it_behaves_like "a moralis client get nfts request"
      end

      context "when the chain is 0x1" do
        let(:chain) { "0x1" }
        let(:formatted_chain) { "0x1" }

        it_behaves_like "a moralis client get nfts request"
      end
    end

    context "when the chain matches the polygon network" do
      let(:chain) { "polygon" }

      context "when the chain is polygon" do
        let(:chain) { "polygon" }
        let(:formatted_chain) { "polygon" }

        it_behaves_like "a moralis client get nfts request"
      end

      context "when the chain is 0x89" do
        let(:chain) { "0x89" }
        let(:formatted_chain) { "0x89" }

        it_behaves_like "a moralis client get nfts request"
      end

      context "when the chain is 137" do
        let(:chain) { 137 }
        let(:formatted_chain) { "0x89" }

        it_behaves_like "a moralis client get nfts request"
      end
    end

    context "when the chain matches the celo network" do
      let(:chain) { "celo" }

      context "when the chain is celo" do
        let(:chain) { "celo" }

        it_behaves_like "a tatum client get nfts request", "CELO"
      end

      context "when the chain is 0xa4ec" do
        let(:chain) { "0xa4ec" }

        it_behaves_like "a tatum client get nfts request", "CELO"
      end

      context "when the chain is 42220" do
        let(:chain) { 42220 }

        it_behaves_like "a tatum client get nfts request", "CELO"
      end
    end

    context "when the chain is not yet supported" do
      let(:chain) { "bsc" }

      it_behaves_like "an unsupported chain request", :retrieve_nfts
    end
  end

  describe "#retrieve_polygon_nfts_count" do
    subject(:request) { api_proxy.retrieve_polygon_nfts_count(address: wallet_address) }

    let(:client_class) { Web3Api::Moralis::Client }
    let(:client) { instance_double(client_class) }

    before do
      allow(client_class).to receive(:new).and_return(client)
      allow(client).to receive(:retrieve_contract_nfts).and_return(response)
    end

    let(:response) do
      OpenStruct.new(
        success?: response_success,
        body: file_fixture("moralis_get_contract_nfts_response.json").read
      )
    end
    let(:response_success) { true }

    it "initializes and calls the moralis client with the correct arguments" do
      request

      expect(client_class).to have_received(:new)
      expect(client).to have_received(:retrieve_contract_nfts).with(
        contract_address: wallet_address,
        chain: "polygon"
      )
    end

    it "returns a the total number of nfts" do
      expect(request).to eq(593)
    end

    context "when the request is not successful" do
      let(:response_success) { false }

      it "raises an api client error" do
        expect { request }.to raise_error(described_class::ApiClientRequestError)
      end
    end
  end

  describe "#retrieve_transactions count" do
    subject(:request) { api_proxy.retrieve_transactions_count(address: wallet_address, start_timestamp: start_timestamp, chain: chain) }

    context "when the chain matches ethereum network" do
      context "when the chain is eth" do
        let(:chain) { "eth" }
        let(:formatted_chain) { "eth" }

        it_behaves_like "a moralis client get transactions count request"
      end

      context "when the chain is 1" do
        let(:chain) { 1 }
        let(:formatted_chain) { "0x1" }

        it_behaves_like "a moralis client get transactions count request"
      end

      context "when the chain is 0x1" do
        let(:chain) { "0x1" }
        let(:formatted_chain) { "0x1" }

        it_behaves_like "a moralis client get transactions count request"
      end
    end

    context "when the chain matches the polygon network" do
      let(:chain) { "polygon" }

      context "when the chain is polygon" do
        let(:chain) { "polygon" }
        let(:formatted_chain) { "polygon" }

        it_behaves_like "a moralis client get transactions count request"
      end

      context "when the chain is 0x89" do
        let(:chain) { "0x89" }
        let(:formatted_chain) { "0x89" }

        it_behaves_like "a moralis client get transactions count request"
      end

      context "when the chain is 137" do
        let(:chain) { 137 }
        let(:formatted_chain) { "0x89" }

        it_behaves_like "a moralis client get transactions count request"
      end
    end

    context "when the chain matches the celo network" do
      let(:chain) { "celo" }

      context "when the chain is celo" do
        let(:chain) { "celo" }

        it_behaves_like "a celo explorer client get transactions count request"
      end

      context "when the chain is 0xa4ec" do
        let(:chain) { "0xa4ec" }

        it_behaves_like "a celo explorer client get transactions count request"
      end

      context "when the chain is 42220" do
        let(:chain) { 42220 }

        it_behaves_like "a celo explorer client get transactions count request"
      end
    end

    context "when the chain is not yet supported" do
      let(:chain) { "bsc" }

      it_behaves_like "an unsupported chain request", :retrieve_transactions_count
    end
  end

  describe "#retrieve_poaps" do
    subject(:request) { api_proxy.retrieve_poaps(wallet_address: wallet_address) }

    it_behaves_like "a gnosis chain explorer client get tokens request"
  end
end
