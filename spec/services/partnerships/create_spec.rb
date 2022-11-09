require "rails_helper"

RSpec.describe Partnerships::Create do
  subject(:create_partnership) do
    described_class.new(max_uses: max_uses, params: params).call
  end

  let(:max_uses) { 3 }

  let(:params) do
    {
      name: "Talent Protocol Core Team",
      description: "Team building Talent Protocol.",
      website_url: "https://www.talentprotocol.com",
      twitter_url: "https://twitter.com/talentprotocol"
    }
  end

  let(:invites_create_class) { Invites::Create }
  let(:invites_create) { instance_double(invites_create_class, call: true) }

  before do
    allow(invites_create_class).to receive(:new).and_return(invites_create)
  end

  it "creates the partnership with the correct params" do
    expect { create_partnership }.to change(Partnership, :count).from(0).to(1)

    partnership = Partnership.last

    aggregate_failures do
      expect(partnership.name).to eq "Talent Protocol Core Team"
      expect(partnership.description).to eq "Team building Talent Protocol."
      expect(partnership.website_url).to eq "https://www.talentprotocol.com"
      expect(partnership.twitter_url).to eq "https://twitter.com/talentprotocol"
    end
  end

  it "initialises and calls the invite create with the correct arguments" do
    partnership = create_partnership

    aggregate_failures do
      expect(invites_create_class).to have_received(:new)
        .with(max_uses: max_uses, partnership: partnership, talent_invite: true)

      expect(invites_create).to have_received(:call)
    end
  end

  context "when the params are not valid" do
    let(:params) { {name: nil} }

    it "raises an error" do
      expect { create_partnership }.to raise_error(
        described_class::CreationError,
        "Unable to create partnership. Errors: Name can't be blank"
      )
    end
  end
end
