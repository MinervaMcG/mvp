require "rails_helper"

RSpec.describe RefreshDomainsJob, type: :job do
  let(:user) { create :user }

  subject(:talent_supporters_refresh) { RefreshDomainsJob.perform_now(user.id) }

  let(:refresh_domains_class) { Web3::RefreshDomains }
  let(:refresh_domains_service) { instance_double(refresh_domains_class, call: true) }

  before do
    allow(refresh_domains_class).to receive(:new).and_return(refresh_domains_service)
  end

  it "initializes and calls the talent supporters refresh service with the correct arguments" do
    talent_supporters_refresh

    aggregate_failures do
      expect(refresh_domains_class).to have_received(:new).with(
        user: user
      )
      expect(refresh_domains_service).to have_received(:call)
    end
  end
end
