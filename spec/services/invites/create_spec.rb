require "rails_helper"

RSpec.describe Invites::Create do
  include ActiveJob::TestHelper

  subject(:create_invite) { described_class.new(params).call }

  let(:params) do
    {
      max_uses: max_uses,
      partnership: partnership,
      talent_invite: talent_invite,
      user: user
    }.compact
  end

  let(:max_uses) { nil }
  let(:partnership) { nil }
  let(:talent_invite) { nil }
  let(:user) { create :user, username: "jack" }

  before do
    allow(Invite).to receive(:generate_code).and_return("CODE")
  end

  context "when a user is passed" do
    it "creates an invite for the user" do
      expect { create_invite }.to change { Invite.count }.by(1)

      invite = Invite.last

      aggregate_failures do
        expect(invite.code).to eq(user.username)
        expect(invite.max_uses).to be_nil
        expect(invite.partnership).to be_nil
        expect(invite.talent_invite).to be_falsey
        expect(invite.user).to eq(user)
      end
    end

    context "when max uses is passed" do
      let(:max_uses) { 3 }

      it "assigns the max uses to the invite" do
        invite = create_invite

        expect(invite.max_uses).to eq(3)
      end
    end

    context "when the user already has an invite with the same talent_invite attribute" do
      let!(:invite) { create :invite, talent_invite: false, user: user }

      it "does not create an invite" do
        expect { create_invite }.not_to change(Invite, :count)
      end

      it "returns the invite" do
        expect(create_invite).to eq(invite)
      end
    end

    context "when there is already an invite with their username as the code" do
      before do
        create :invite, code: user.username
      end

      it "assigns a generated code for the invite" do
        invite = create_invite

        expect(invite.code).to eq("#{user.username}-CODE")
      end

      context "when it is a talent invite" do
        let(:talent_invite) { true }

        it "assigns a generated code for the invite" do
          invite = create_invite

          expect(invite.code).to eq("#{user.username}-CODE")
        end
      end
    end
  end

  context "when a partnership is passed" do
    let(:partnership) { create :partnership }
    let(:user) { nil }

    it "creates an invite for the partnership" do
      expect { create_invite }.to change { Invite.count }.by(1)

      invite = Invite.last

      aggregate_failures do
        expect(invite.code).to eq(partnership.name.parameterize)
        expect(invite.max_uses).to be_nil
        expect(invite.partnership).to eq(partnership)
        expect(invite.talent_invite).to be_falsey
        expect(invite.user).to be_nil
      end
    end

    context "when max uses is passed" do
      let(:max_uses) { 3 }

      it "assigns the max uses to the invite" do
        invite = create_invite

        expect(invite.max_uses).to eq(3)
      end
    end

    context "when the partnership already has an invite with the same talent_invite attribute" do
      let!(:invite) { create :partnership_invite, talent_invite: false, partnership: partnership }

      it "does not create an invite" do
        expect { create_invite }.not_to change(Invite, :count)
      end

      it "returns the invite" do
        expect(create_invite).to eq(invite)
      end
    end
  end
end
