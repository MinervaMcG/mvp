require "rails_helper"

RSpec.shared_examples "a profile picture uploader" do
  it "persists the profile picture to the user's talent" do
    login_unstoppable_user

    aggregate_failures do
      expect(Down).to have_received(:open).with("profile_picture_url").at_least(:once)
      expect(talent).to have_received(:profile_picture=).with(chunked_io)
    end
  end
end

RSpec.describe UnstoppableDomains::LoginUser do
  subject(:login_unstoppable_user) do
    described_class.new(params).call
  end

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

  let(:verify_wallet_class) { Web3::VerifyWallet }
  let(:verify_wallet) { instance_double(verify_wallet_class, call: true) }

  let(:creator_class) { Users::Create }
  let(:creator) { instance_double(creator_class, call: result) }
  let(:result) { {success: true, user: user} }
  let(:user) { create :user, talent: talent }
  let(:talent) { create :talent }

  let(:chunked_io) do
    instance_double(Down::ChunkedIO, close: true, eof?: true, read: true, rewind: true)
  end

  before do
    allow(verify_wallet_class).to receive(:new).and_return(verify_wallet)
    allow(creator_class).to receive(:new).and_return(creator)
    allow(SecureRandom).to receive(:hex).and_return("314835")
    allow(Down).to receive(:open).and_return(chunked_io)
    allow(talent).to receive(:profile_picture=)
    allow(talent).to receive(:save!)
  end

  describe "#call" do
    it "initialises and calls the user creator with the correct arguments" do
      login_unstoppable_user

      aggregate_failures do
        expect(verify_wallet_class).to have_received(:new).with(
          wallet_address,
          "signature",
          "message"
        )

        expect(verify_wallet).to have_received(:call)
      end
    end

    context "when the user creator is not successfull" do
      before do
        allow(creator).to receive(:call).and_return({success: false})
      end

      it "raises a user creation error" do
        expect { login_unstoppable_user }.to raise_error(described_class::UserCreationError)
      end
    end

    context "when the validate wallet returns false" do
      before do
        allow(verify_wallet).to receive(:call).and_return(false)
      end

      it "raises a user creation error" do
        expect { login_unstoppable_user }.to raise_error(described_class::WalletVerificationError)
      end
    end

    context "when there is a user with the wallet address passed" do
      before do
        allow(User).to receive(:find_by).with(wallet_id: wallet_address).and_return(user)
      end

      it_behaves_like "a profile picture uploader"

      it "does not create a new user" do
        expect { login_unstoppable_user }.not_to change(User, :count)
      end

      it "does not enqueue a job to add user to Mailerlite" do
        login_unstoppable_user

        expect(AddUsersToMailerliteJob).not_to have_been_enqueued.with(user.id)
      end
    end

    context "when there is a user with the email passed" do
      before do
        allow(User).to receive(:find_by).with(wallet_id: wallet_address).and_return(nil)
        allow(User).to receive(:find_by).with(email: email).and_return(user)
      end

      it_behaves_like "a profile picture uploader"

      it "does not create a new user" do
        expect { login_unstoppable_user }.not_to change(User, :count)
      end

      it "does not enqueue a job to add user to Mailerlite" do
        login_unstoppable_user

        expect(AddUsersToMailerliteJob).not_to have_been_enqueued.with(user.id)
      end
    end

    context "when there is no user with the email address" do
      it "initialises and calls the user creator with the correct arguments" do
        login_unstoppable_user

        aggregate_failures do
          expect(creator_class).to have_received(:new)

          expect(creator).to have_received(:call)
            .with(
              legal_first_name: "Unstoppable",
              legal_last_name: "Dinis",
              display_name: "Unstoppable Dinis",
              email: email,
              password: "314835",
              username: "unstoppabledinis",
              wallet_id: wallet_address
            )
        end
      end

      it "enqueues a job to add user to Mailerlite" do
        login_unstoppable_user

        expect(AddUsersToMailerliteJob).to have_been_enqueued.with(user.id)
      end

      it_behaves_like "a profile picture uploader"

      it "returns the user" do
        expect(login_unstoppable_user).to eq(user)
      end
    end
  end
end
