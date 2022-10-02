require "rails_helper"
require "web3/api_proxy"

RSpec.shared_examples "an nft creation" do
end

RSpec.describe Web3::RefreshUserTokens do
  let(:web3_proxy_class) { Web3::ApiProxy }
  let(:web3_proxy) { instance_double(web3_proxy_class) }

  before do
    allow(web3_proxy_class).to receive(:new).and_return(web3_proxy)
    allow(web3_proxy).to receive(:retrieve_tokens).and_return(tokens_response)
    allow(web3_proxy).to receive(:retrieve_nfts).and_return(nfts_response)
    allow(web3_proxy).to receive(:retrieve_poaps).and_return(poaps_response)
  end

  let(:tokens_response) do
    [
      {
        address: "aaa",
        name: "Token",
        symbol: "T",
        logo: nil,
        thumbnail: nil,
        decimals: "10",
        balance: "10000000"
      },
      {
        address: "bbb",
        name: "Ethereum",
        symbol: "eth",
        logo: nil,
        thumbnail: nil,
        decimals: "18",
        balance: "1000000000"
      }
    ]
  end

  let(:nfts_response) do
    [
      {
        address: "ccc",
        token_id: "5",
        amount: "1",
        name: "CeloApesKingdom",
        symbol: "CAK",
        token_uri: "https://ipfs.io/ipfs/bafybeih6g4g7ul4s3l2b6axygpf7s6fkpwhd6e5elgl2t7gmdwlc6lsmjq/metadata/5.json",
        metadata: {}
      },
      {
        address: "ddd",
        token_id: "8",
        amount: "1",
        name: "CeloApesKingdom",
        symbol: "CAK",
        token_uri: "https://ipfs.io/ipfs/bafybeih6g4g7ul4s3l2b6axygpf7s6fkpwhd6e5elgl2t7gmdwlc6lsmjq/metadata/8.json",
        metadata: {}
      }
    ]
  end

  let(:poaps_response) do
    [
      {
        token_id: "10",
        address: "eee"
      }
    ]
  end

  let(:user) { create :user, wallet_id: wallet_id }
  let(:wallet_id) { SecureRandom.hex }

  subject(:refresh_user_tokens) { described_class.new(user: user, scope: scope, chain: chain).call }

  context "when the scope is all" do
    let(:scope) { "all" }

    context "when a specific chain is passed" do
      let(:chain) { "eth" }

      it "initializes the web3 proxy class once" do
        refresh_user_tokens

        expect(web3_proxy_class).to have_received(:new).once
      end

      it "calls the web3 proxy instance three times" do
        refresh_user_tokens

        aggregate_failures do
          expect(web3_proxy).to have_received(:retrieve_tokens).with(
            wallet_address: wallet_id,
            chain: "eth"
          )
          expect(web3_proxy).to have_received(:retrieve_nfts).with(
            wallet_address: wallet_id,
            chain: "eth"
          )
          expect(web3_proxy).to have_received(:retrieve_poaps).with(
            wallet_address: wallet_id
          )
        end
      end
    end

    context "when the chain is set to all" do
      let(:chain) { "all" }

      it "initializes the web3 proxy class once" do
        refresh_user_tokens

        aggregate_failures do
          expect(web3_proxy_class).to have_received(:new).once
        end
      end

      it "calls the retrieve tokens method for alls chains" do
        refresh_user_tokens

        aggregate_failures do
          web3_proxy_class::SUPPORTED_CHAIN_NAMES.each do |chain|
            expect(web3_proxy).to have_received(:retrieve_tokens).with(
              wallet_address: wallet_id,
              chain: chain
            )
          end
        end
      end

      it "calls the retrieve nfts method for alls chains" do
        refresh_user_tokens

        aggregate_failures do
          web3_proxy_class::SUPPORTED_CHAIN_NAMES.each do |chain|
            expect(web3_proxy).to have_received(:retrieve_nfts).with(
              wallet_address: wallet_id,
              chain: chain
            )
          end
        end
      end

      it "calls the retrieve poaps method once" do
        refresh_user_tokens

        expect(web3_proxy).to have_received(:retrieve_poaps).with(
          wallet_address: wallet_id
        )
      end
    end
  end

  context "when the scope is tokens" do
    let(:scope) { "tokens" }

    context "when a specific chain is passed" do
      let(:chain) { "eth" }

      it "initializes the web3 proxy class once" do
        refresh_user_tokens

        expect(web3_proxy_class).to have_received(:new).once
      end

      it "calls the web3 proxy instance three times" do
        refresh_user_tokens

        aggregate_failures do
          expect(web3_proxy).to have_received(:retrieve_tokens).with(
            wallet_address: wallet_id,
            chain: "eth"
          ).once
        end
      end

      it "creates 2 new tokens in the database" do
        expect { refresh_user_tokens }.to change(Erc20Token, :count).from(0).to(2)
      end

      it "creates the tokens with the correct data" do
        freeze_time do
          refresh_user_tokens

          tokens = Erc20Token.last(2)

          aggregate_failures do
            expect(tokens.pluck(:address)).to match_array(["aaa", "bbb"])
            expect(tokens.pluck(:name)).to match_array(["Token", "Ethereum"])
            expect(tokens.pluck(:symbol)).to match_array(["T", "eth"])
            expect(tokens.pluck(:chain_id)).to match_array([1, 1])
            expect(tokens.pluck(:decimals)).to match_array([10, 18])
            expect(tokens.pluck(:balance)).to match_array(["10000000", "1000000000"])
            expect(tokens.pluck(:show)).to match_array([false, false])
            expect(tokens.pluck(:last_sync_at)).to match_array([Time.zone.now, Time.zone.now])
          end
        end
      end

      context "when one of the tokens was already imported" do
        let!(:existing_token) { create :erc20_token, address: "aaa", chain_id: 1, show: true, user: user }

        it "only creates one new token in the database" do
          expect { refresh_user_tokens }.to change(Erc20Token, :count).from(1).to(2)
        end

        it "keeps the token showing" do
          expect { refresh_user_tokens }.not_to change(existing_token, :show)
        end
      end
    end

    context "when the chain is set to all" do
      let(:chain) { "all" }

      it "initializes the web3 proxy class once" do
        refresh_user_tokens

        aggregate_failures do
          expect(web3_proxy_class).to have_received(:new).once
        end
      end

      it "does not call the retrieve nfts method" do
        refresh_user_tokens

        expect(web3_proxy).not_to have_received(:retrieve_nfts)
      end

      it "calls the retrieve tokens method for alls chains" do
        refresh_user_tokens

        aggregate_failures do
          web3_proxy_class::SUPPORTED_CHAIN_NAMES.each do |chain|
            expect(web3_proxy).to have_received(:retrieve_tokens).with(
              wallet_address: wallet_id,
              chain: chain
            )
          end
        end
      end

      it "does not call the retrieve poaps" do
        refresh_user_tokens

        expect(web3_proxy).not_to have_received(:retrieve_poaps)
      end

      it "creates 6 new tokens in the database" do
        expect { refresh_user_tokens }.to change(Erc20Token, :count).from(0).to(6)
      end
    end
  end

  context "when the scope is nfts" do
    let(:scope) { "nfts" }

    context "when a specific chain is passed" do
      let(:chain) { "eth" }

      it "initializes the web3 proxy class once" do
        refresh_user_tokens

        expect(web3_proxy_class).to have_received(:new).once
      end

      it "calls the web3 proxy instance three times" do
        refresh_user_tokens

        aggregate_failures do
          expect(web3_proxy).to have_received(:retrieve_nfts).with(
            wallet_address: wallet_id,
            chain: "eth"
          ).once
        end
      end

      it "creates 2 new nfts in the database" do
        expect { refresh_user_tokens }.to change(Erc721Token, :count).from(0).to(2)
      end

      it "creates the tokens with the correct data" do
        freeze_time do
          refresh_user_tokens

          tokens = Erc721Token.last(2)

          aggregate_failures do
            expect(tokens.pluck(:address)).to match_array(["ccc", "ddd"])
            expect(tokens.pluck(:nft_type)).to match_array(["nft", "nft"])
            expect(tokens.pluck(:name)).to match_array(["CeloApesKingdom", "CeloApesKingdom"])
            expect(tokens.pluck(:symbol)).to match_array(["CAK", "CAK"])
            expect(tokens.pluck(:token_id)).to match_array(["5", "8"])
            expect(tokens.pluck(:chain_id)).to match_array([1, 1])
            expect(tokens.pluck(:show)).to match_array([false, false])
            expect(tokens.pluck(:last_sync_at)).to match_array([Time.zone.now, Time.zone.now])
            expect(tokens.pluck(:url)).to match_array(
              [
                "https://ipfs.io/ipfs/bafybeih6g4g7ul4s3l2b6axygpf7s6fkpwhd6e5elgl2t7gmdwlc6lsmjq/metadata/5.json",
                "https://ipfs.io/ipfs/bafybeih6g4g7ul4s3l2b6axygpf7s6fkpwhd6e5elgl2t7gmdwlc6lsmjq/metadata/8.json"
              ]
            )
          end
        end
      end

      context "when one of the nfts was already imported" do
        let!(:existing_nft) { create :erc721_token, address: "ccc", token_id: "5", nft_type: "nft", chain_id: 1, show: true, user: user }

        it "only creates one new nft in the database" do
          expect { refresh_user_tokens }.to change(Erc721Token, :count).from(1).to(2)
        end

        it "keeps the nft showing" do
          expect { refresh_user_tokens }.not_to change(existing_nft, :show)
        end
      end
    end

    context "when the chain is set to all" do
      let(:chain) { "all" }

      it "initializes the web3 proxy class once" do
        refresh_user_tokens

        aggregate_failures do
          expect(web3_proxy_class).to have_received(:new).once
        end
      end

      it "does not call the retrieve tokens method" do
        refresh_user_tokens

        expect(web3_proxy).not_to have_received(:retrieve_tokens)
      end

      it "calls the retrieve nfts method for alls chains" do
        refresh_user_tokens

        aggregate_failures do
          web3_proxy_class::SUPPORTED_CHAIN_NAMES.each do |chain|
            expect(web3_proxy).to have_received(:retrieve_nfts).with(
              wallet_address: wallet_id,
              chain: chain
            )
          end
        end
      end

      it "does not call the retrieve poaps" do
        refresh_user_tokens

        expect(web3_proxy).not_to have_received(:retrieve_poaps)
      end

      it "creates 6 new nfts in the database" do
        expect { refresh_user_tokens }.to change(Erc721Token, :count).from(0).to(6)
      end
    end
  end

  context "when the scope is poaps" do
    let(:scope) { "poaps" }
    let(:chain) { nil }

    it "initializes the web3 proxy class once" do
      refresh_user_tokens

      expect(web3_proxy_class).to have_received(:new).once
    end

    it "calls the web3 proxy instance once" do
      refresh_user_tokens

      expect(web3_proxy).to have_received(:retrieve_poaps).with(
        wallet_address: wallet_id
      ).once
    end

    it "creates 2 new nfts in the database" do
      expect { refresh_user_tokens }.to change(Erc721Token, :count).from(0).to(1)
    end

    it "creates the tokens with the correct data" do
      freeze_time do
        refresh_user_tokens

        token = Erc721Token.last

        aggregate_failures do
          expect(token.address).to eq "eee"
          expect(token.nft_type).to eq "poap"
          expect(token.token_id).to eq "10"
          expect(token.chain_id).to eq 100
          expect(token.last_sync_at).to eq Time.zone.now
        end
      end
    end

    context "when the nft was already imported" do
      let!(:existing_nft) { create :erc721_token, address: "eee", token_id: "10", nft_type: "poap", chain_id: 100, show: true, user: user }

      it "does not create a new nft in the database" do
        expect { refresh_user_tokens }.not_to change(Erc721Token, :count)
      end

      it "keeps the nft showing" do
        expect { refresh_user_tokens }.not_to change(existing_nft, :show)
      end
    end
  end

  context "when an invalid scope is passed" do
    let(:scope) { "invalid" }
    let(:chain) { "all " }

    it "raises an initialization error" do
      expect { described_class.new(user: user, scope: scope, chain: chain) }.to raise_error(described_class::InvalidScopeError)
    end
  end
end
