require "rails_helper"

RSpec.describe "OAuth callbacks", type: :request do
  describe "#unstoppable_domains" do
    subject(:unstoppable_domains_login) { post auth_unstoppable_domains_login_path(params) }

    let(:params) do
      {
        name: "Unstoppable Dinis",
        picture: "profile_picture_url",
        email: email,
        wallet_address: wallet_address,
        eip4361_signature: "signature",
        eip4361_message: "message"
      }
    end

    let(:wallet_address) { "12345" }
    let(:email) { "dinis@unstoppable.blockchain" }

    let(:login_class) { UnstoppableDomains::LoginUser }
    let(:login) { instance_double(login_class, call: user) }

    let(:user) { create :user }

    before do
      allow(login_class).to receive(:new).and_return(login)
    end

    it "returns a successful response" do
      unstoppable_domains_login

      expect(response).to have_http_status(:ok)
    end

    it "initialises and calls the login class with the correct arguments" do
      unstoppable_domains_login

      aggregate_failures do
        expect(login_class).to have_received(:new).with(params)

        expect(login).to have_received(:call)
      end
    end

    context "when the login class raises a wallet verification error" do
      let(:error) { login_class::WalletVerificationError }

      before do
        allow(login).to receive(:call).and_raise(error)
      end

      it "returns a bad response" do
        unstoppable_domains_login

        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when the login class raises a user creation error" do
      let(:error) { login_class::UserCreationError }

      before do
        allow(login).to receive(:call).and_raise(error)
      end

      it "returns a bad response" do
        unstoppable_domains_login

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
