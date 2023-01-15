require "rails_helper"
require "unstoppable_domains/client"

RSpec.describe Web3::RefreshDomains do
  let(:unstoppable_domains_client_class) { UnstoppableDomains::Client }
  let(:unstoppable_domains_client) { instance_double(unstoppable_domains_client_class) }

  before do
    allow(unstoppable_domains_client_class).to receive(:new).and_return(unstoppable_domains_client)
    allow(unstoppable_domains_client).to receive(:get_address_domains).and_return(unstoppable_domains_response)
  end

  let(:unstoppable_domains_response) do
    OpenStruct.new(
      body: file_fixture("unstoppable_domains_response.json").read
    )
  end

  let(:user) { create :user, wallet_id: wallet_id }
  let(:wallet_id) { SecureRandom.hex }

  subject(:refresh_domains) { described_class.new(user: user).call }

  it "initializes the unstoppable domains class" do
    refresh_domains

    expect(unstoppable_domains_client_class).to have_received(:new)
  end

  it "calls the unstoppable domains instance" do
    refresh_domains

    expect(unstoppable_domains_client).to have_received(:get_address_domains).with(
      address: wallet_id
    )
  end

  it "creates a user domain record" do
    expect { refresh_domains }.to change(UserDomain, :count).from(0).to(1)
  end

  it "creates the user domain record with the correct values" do
    refresh_domains

    user_domain = UserDomain.last

    aggregate_failures do
      expect(user_domain.user).to eq user
      expect(user_domain.domain).to eq "talentprotocol.dao"
      expect(user_domain.chain_id).to eq 137
      expect(user_domain.wallet).to eq wallet_id
      expect(user_domain.provider).to eq "unstoppable_domains"
    end
  end

  context "when the user domain already exists" do
    before do
      create :user_domain, user: user, domain: "talentprotocol.dao", chain_id: 137, wallet: wallet_id
    end

    it "does not create a new user domain record" do
      expect { refresh_domains }.not_to change(UserDomain, :count)
    end
  end

  context "when a user without wallet is passed" do
    let(:wallet_id) { nil }

    it "raises an initialization error" do
      expect { described_class.new(user: user) }.to raise_error(described_class::WalletNotDefinedError)
    end
  end
end
