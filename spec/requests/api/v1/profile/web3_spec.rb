require "rails_helper"

RSpec.describe "Web3", type: :request do
  let(:current_user) { create :user }
  let(:refresh_user_tokens_class) { Web3::RefreshUserTokens }
  let(:refresh_user_tokens) { instance_double(refresh_user_tokens_class) }

  before do
    allow(refresh_user_tokens_class).to receive(:new).and_return(refresh_user_tokens)
    allow(refresh_user_tokens).to receive(:call).and_return(true)
  end

  describe "#update" do
    let!(:token) { create :erc20_token, address: address, chain_id: chain_id, user: current_user, show: false }
    let(:token_id) { token.id }
    let(:address) { SecureRandom.hex }
    let(:chain_id) { 1 }

    subject(:update_token) { put api_v1_user_profile_web3_path(user_id: current_user.id, id: token_id, params: params, as: current_user) }

    let(:params) do
      {
        address: address,
        chain_id: chain_id,
        show: true
      }
    end

    it "returns a successful response" do
      update_token

      expect(response).to have_http_status(:ok)
    end

    it "changes the token show" do
      update_token

      expect(token.reload.show).to eq true
    end

    context "when the token is not found" do
      let(:token_id) { -1 }

      it "returns a not found response" do
        update_token

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "#tokens" do
    subject(:get_tokens) { get api_v1_user_profile_tokens_path(user_id: current_user.id, params: params, as: current_user) }

    let(:chain_id) { 1 }

    let!(:token_1) { create :erc20_token, user: current_user, chain_id: chain_id }
    let!(:token_2) { create :erc20_token, user: create(:user), chain_id: chain_id }
    let!(:token_3) { create :erc20_token, user: current_user, chain_id: 8000 }

    context "when a chain id is passed" do
      let(:params) do
        {
          chain_id: chain_id
        }
      end

      it "only returns tokens of the user for that specific chain" do
        get_tokens

        expect(json[:tokens]).to eq [
          {
            id: token_1.id,
            address: token_1.address,
            name: token_1.name,
            symbol: token_1.symbol,
            chain_id: token_1.chain_id,
            logo: token_1.logo,
            thumbnail: token_1.thumbnail,
            decimals: token_1.decimals,
            balance: token_1.balance,
            show: token_1.show
          }
        ]
      end
    end

    context "when a chain id is not passed" do
      let(:params) { {} }

      it "only returns tokens of the user for all chains" do
        get_tokens

        expect(json[:tokens]).to eq [
          {
            id: token_1.id,
            address: token_1.address,
            name: token_1.name,
            symbol: token_1.symbol,
            chain_id: token_1.chain_id,
            logo: token_1.logo,
            thumbnail: token_1.thumbnail,
            decimals: token_1.decimals,
            balance: token_1.balance,
            show: token_1.show
          },
          {
            id: token_3.id,
            address: token_3.address,
            name: token_3.name,
            symbol: token_3.symbol,
            chain_id: token_3.chain_id,
            logo: token_3.logo,
            thumbnail: token_3.thumbnail,
            decimals: token_3.decimals,
            balance: token_3.balance,
            show: token_3.show
          }
        ]
      end
    end
  end

  describe "#nfts" do
    subject(:get_nfts) { get api_v1_user_profile_nfts_path(user_id: current_user.id, params: params, as: current_user) }

    let(:chain_id) { 1 }

    let!(:token_1) { create :erc721_token, user: current_user, chain_id: chain_id, nft_type: "nft" }
    let!(:token_2) { create :erc721_token, user: create(:user), chain_id: chain_id, nft_type: "nft" }
    let!(:token_3) { create :erc721_token, user: current_user, chain_id: 8000, nft_type: "nft" }
    let!(:token_4) { create :erc721_token, user: current_user, chain_id: chain_id, nft_type: "poap" }

    context "when a chain id is passed" do
      let(:params) do
        {
          chain_id: chain_id
        }
      end

      it "only returns nfts of the user for that specific chain" do
        get_nfts

        expect(json[:tokens]).to eq [
          {
            id: token_1.id,
            address: token_1.address,
            name: token_1.name,
            symbol: token_1.symbol,
            chain_id: token_1.chain_id,
            url: token_1.url,
            local_image_url: nil,
            description: nil,
            token_id: token_1.token_id,
            amount: token_1.amount,
            show: token_1.show
          }
        ]
      end
    end

    context "when a chain id is not passed" do
      let(:params) { {} }

      it "returns nfts of the user for all chains" do
        get_nfts

        expect(json[:tokens]).to eq [
          {
            id: token_1.id,
            address: token_1.address,
            name: token_1.name,
            symbol: token_1.symbol,
            chain_id: token_1.chain_id,
            url: token_1.url,
            local_image_url: nil,
            description: nil,
            token_id: token_1.token_id,
            amount: token_1.amount,
            show: token_1.show
          },
          {
            id: token_3.id,
            address: token_3.address,
            name: token_3.name,
            symbol: token_3.symbol,
            chain_id: token_3.chain_id,
            url: token_3.url,
            local_image_url: nil,
            description: nil,
            token_id: token_3.token_id,
            amount: token_3.amount,
            show: token_3.show
          }
        ]
      end
    end
  end

  describe "#poaps" do
    subject(:get_poaps) { get api_v1_user_profile_poaps_path(user_id: current_user.id, as: current_user) }

    let(:chain_id) { 100 }

    let!(:token_1) { create :erc721_token, user: current_user, chain_id: chain_id, nft_type: "poap" }
    let!(:token_2) { create :erc721_token, user: create(:user), chain_id: chain_id, nft_type: "poap" }
    let!(:token_3) { create :erc721_token, user: current_user, chain_id: chain_id, nft_type: "poap" }
    let!(:token_4) { create :erc721_token, user: current_user, chain_id: chain_id, nft_type: "nft" }

    it "only returns poaps of the user" do
      get_poaps

      expect(json[:tokens]).to eq [
        {
          id: token_1.id,
          address: token_1.address,
          name: token_1.name,
          symbol: token_1.symbol,
          chain_id: token_1.chain_id,
          local_image_url: nil,
          description: nil,
          url: token_1.url,
          token_id: token_1.token_id,
          amount: token_1.amount,
          show: token_1.show
        },
        {
          id: token_3.id,
          address: token_3.address,
          name: token_3.name,
          symbol: token_3.symbol,
          chain_id: token_3.chain_id,
          local_image_url: nil,
          description: nil,
          url: token_3.url,
          token_id: token_3.token_id,
          amount: token_3.amount,
          show: token_3.show
        }
      ]
    end
  end

  describe "#refresh_tokens" do
    let(:chain_id) { 1 }

    let(:params) do
      {
        chain_id: chain_id
      }
    end

    subject(:refresh_tokens) { post api_v1_user_profile_refresh_tokens_path(user_id: current_user.id, params: params, as: current_user) }

    let!(:token_1) { create :erc20_token, user: current_user, chain_id: chain_id }
    let!(:token_2) { create :erc20_token, user: create(:user), chain_id: chain_id }
    let!(:token_3) { create :erc20_token, user: current_user, chain_id: 8000 }

    it "initializes and calls the refresh user tokens service with the correct arguments" do
      refresh_tokens

      aggregate_failures do
        expect(refresh_user_tokens_class).to have_received(:new).with(
          user: current_user,
          scope: "tokens",
          chain: chain_id.to_s
        )
      end
    end

    it "only returns tokens of the user for that specific chain" do
      refresh_tokens

      expect(json[:tokens]).to eq [
        {
          id: token_1.id,
          address: token_1.address,
          name: token_1.name,
          symbol: token_1.symbol,
          chain_id: token_1.chain_id,
          logo: token_1.logo,
          thumbnail: token_1.thumbnail,
          decimals: token_1.decimals,
          balance: token_1.balance,
          show: token_1.show
        }
      ]
    end
  end

  describe "#refresh_nfts" do
    let(:chain_id) { 1 }

    let(:params) do
      {
        chain_id: chain_id
      }
    end

    subject(:refresh_nfts) { post api_v1_user_profile_refresh_nfts_path(user_id: current_user.id, params: params, as: current_user) }

    let!(:token_1) { create :erc721_token, user: current_user, chain_id: chain_id, nft_type: "nft" }
    let!(:token_2) { create :erc721_token, user: create(:user), chain_id: chain_id, nft_type: "nft" }
    let!(:token_3) { create :erc721_token, user: current_user, chain_id: 8000, nft_type: "nft" }
    let!(:token_4) { create :erc721_token, user: current_user, chain_id: chain_id, nft_type: "poap" }

    it "initializes and calls the refresh user nfts service with the correct arguments" do
      refresh_nfts

      aggregate_failures do
        expect(refresh_user_tokens_class).to have_received(:new).with(
          user: current_user,
          scope: "nfts",
          chain: chain_id.to_s
        )
      end
    end

    it "only returns nfts of the user for that specific chain" do
      refresh_nfts

      expect(json[:tokens]).to eq [
        {
          id: token_1.id,
          address: token_1.address,
          name: token_1.name,
          symbol: token_1.symbol,
          chain_id: token_1.chain_id,
          url: token_1.url,
          local_image_url: nil,
          description: nil,
          token_id: token_1.token_id,
          amount: token_1.amount,
          show: token_1.show
        }
      ]
    end
  end

  describe "#refresh_poaps" do
    let(:chain_id) { 100 }

    let(:params) do
      {
        chain_id: chain_id
      }
    end

    subject(:refresh_poaps) { post api_v1_user_profile_refresh_poaps_path(user_id: current_user.id, params: params, as: current_user) }

    let!(:token_1) { create :erc721_token, user: current_user, chain_id: chain_id, nft_type: "poap" }
    let!(:token_2) { create :erc721_token, user: create(:user), chain_id: chain_id, nft_type: "poap" }
    let!(:token_3) { create :erc721_token, user: current_user, chain_id: chain_id, nft_type: "poap" }
    let!(:token_4) { create :erc721_token, user: current_user, chain_id: chain_id, nft_type: "nft" }

    it "initializes and calls the refresh user poaps service with the correct arguments" do
      refresh_poaps

      aggregate_failures do
        expect(refresh_user_tokens_class).to have_received(:new).with(
          user: current_user,
          scope: "poaps"
        )
      end
    end

    it "it only returns poaps of the user" do
      refresh_poaps

      expect(json[:tokens]).to eq [
        {
          id: token_1.id,
          address: token_1.address,
          name: token_1.name,
          symbol: token_1.symbol,
          chain_id: token_1.chain_id,
          url: token_1.url,
          local_image_url: nil,
          description: nil,
          token_id: token_1.token_id,
          amount: token_1.amount,
          show: token_1.show
        },
        {
          id: token_3.id,
          address: token_3.address,
          name: token_3.name,
          symbol: token_3.symbol,
          chain_id: token_3.chain_id,
          url: token_3.url,
          local_image_url: nil,
          description: nil,
          token_id: token_3.token_id,
          amount: token_3.amount,
          show: token_3.show
        }
      ]
    end
  end
end
