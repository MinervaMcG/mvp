require "rails_helper"

RSpec.describe Users::Update do
  include ActiveJob::TestHelper

  subject(:update_user) do
    described_class.new(
      user: user,
      user_params: user_params,
      password_params: password_params,
      tal_domain: tal_domain,
      wallet_id: wallet_id,
      first_quest_popup: first_quest_popup
    ).call
  end

  let(:user) { create :user }
  let(:user_params) { {} }
  let(:password_params) { {} }
  let(:tal_domain) { nil }
  let(:wallet_id) { nil }
  let(:first_quest_popup) { nil }

  context "when the wallet_id is passed" do
    let(:wallet_id) { SecureRandom.hex }

    let(:refresh_domains_class) { Web3::RefreshDomains }
    let(:refresh_domains) { instance_double(refresh_domains_class, call: true) }

    before do
      allow(refresh_domains_class).to receive(:new).and_return(refresh_domains)
    end

    it "updates the user wallet_id" do
      update_user

      expect(user.reload.wallet_id).to eq wallet_id
    end

    it "initializes and calls the refresh domains service" do
      update_user

      expect(refresh_domains_class).to have_received(:new).with(
        user: user
      )
      expect(refresh_domains).to have_received(:call)
    end

    it "enqueues two jobs related with wallet changes" do
      Sidekiq::Testing.inline! do
        update_user

        job_classes = enqueued_jobs.pluck("job_class")

        aggregate_failures do
          expect(job_classes).to match_array(["AddUsersToMailerliteJob", "UpdateTasksJob"])
        end
      end
    end

    it "returns a successful result" do
      expect(update_user).to eq(
        {
          user: user,
          success: true
        }
      )
    end

    context "when the wallet id is already assigned to another user" do
      before do
        create :user, wallet_id: wallet_id
      end

      it "does not update the user wallet_id" do
        update_user

        expect(user.reload.wallet_id).not_to eq wallet_id
      end

      it "returns an unsuccessful result" do
        expect(update_user).to eq(
          {
            errors: "Wallet already exists in the system",
            success: false
          }
        )
      end
    end
  end

  context "when the tal_domain is passed" do
    let(:tal_domain) { "dinis.tal.community" }

    let(:ens_domain_owner_class) { Web3::EnsDomainOwner }
    let(:ens_domain_owner) { instance_double(ens_domain_owner_class, call: domain_owner) }
    let(:domain_owner) { SecureRandom.hex }

    before do
      allow(ens_domain_owner_class).to receive(:new).and_return(ens_domain_owner)
    end

    it "initializes and calls the refresh domains service" do
      update_user

      expect(ens_domain_owner_class).to have_received(:new).with(
        domain: tal_domain
      )
      expect(ens_domain_owner).to have_received(:call)
    end

    context "when the domain owner matches the user wallet" do
      let(:domain_owner) { user.wallet_id }

      it "creates a new user domain" do
        expect { update_user }.to change(UserDomain, :count).from(0).to(1)
      end
    end

    context "when the domain owner is not the user" do
      let(:domain_owner) { SecureRandom.hex }

      it "does not create a new user domain" do
        expect { update_user }.not_to change(UserDomain, :count)
      end

      it "returns an unsuccessful result" do
        expect(update_user).to eq(
          {
            errors: {talDomain: "Your wallet does not own the domain specified"},
            success: false
          }
        )
      end
    end

    context "when the domain does not have a owner" do
      let(:domain_owner) { nil }

      it "does not create a new user domain" do
        expect { update_user }.not_to change(UserDomain, :count)
      end

      it "returns an unsuccessful result" do
        expect(update_user).to eq(
          {
            errors: {talDomain: "Your wallet does not own the domain specified"},
            success: false
          }
        )
      end
    end
  end
end
