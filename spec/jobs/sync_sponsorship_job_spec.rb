require "rails_helper"

RSpec.describe SyncSponsorshipJob, type: :job do
  let(:user) { create :user }

  let(:tx) { SecureRandom.hex }
  subject(:sync_sponsorship) { SyncSponsorshipJob.perform_now(tx) }

  let(:sponsorship_sync_class) { Web3::SponsorshipSync }
  let(:sponsorship_sync_service) { instance_double(sponsorship_sync_class, call: true) }

  before do
    allow(sponsorship_sync_class).to receive(:new).and_return(sponsorship_sync_service)
  end

  it "initializes and calls the sync sponsorship refresh service with the correct arguments" do
    sync_sponsorship

    aggregate_failures do
      expect(sponsorship_sync_class).to have_received(:new)
      expect(sponsorship_sync_service).to have_received(:call).with(
        tx
      )
    end
  end
end