require "rails_helper"

RSpec.describe Invite, type: :model do
  describe "validations" do
    describe "#partnership_or_user" do
      let(:invite) { build :invite, partnership: partnership, user: user }

      before { invite.save }

      context "when there is a partnership" do
        let(:partnership) { create :partnership }
        let(:user) { nil }

        it "does not add any errors to the invite" do
          expect(invite.errors.to_a).to be_empty
        end
      end

      context "when there is a user" do
        let(:partnership) { nil }
        let(:user) { create :user }

        it "does not add any errors to the invite" do
          expect(invite.errors.to_a).to be_empty
        end
      end

      context "when there is a partnership and a user" do
        let(:partnership) { create :partnership }
        let(:user) { create :user }

        it "adds an error to the invite" do
          expect(invite.errors.to_a).to eq(["Partnership and user can't both be present"])
        end
      end

      context "when there is no partnership or user" do
        let(:partnership) { nil }
        let(:user) { nil }

        it "adds an error to the invite" do
          expect(invite.errors.to_a).to eq(["Partnership or user can't both be blank"])
        end
      end
    end
  end

  describe "name" do
    let(:invite) { create :invite, partnership: partnership, user: user }

    context "when there is a partnership" do
      let(:partnership) { create :partnership }
      let(:user) { nil }

      it "returns the name of the partnership" do
        expect(invite.name).to eq(partnership.name)
      end
    end

    context "when there is a user" do
      let(:partnership) { nil }
      let(:user) { create :user }

      it "returns the name of the user" do
        expect(invite.name).to eq(user.name)
      end
    end
  end

  describe "profile_picture_url" do
    let(:invite) { create :invite, partnership: partnership, user: user }

    context "when there is a partnership" do
      let(:partnership) { create :partnership }
      let(:user) { nil }

      before do
        allow(partnership).to receive(:logo_url).and_return("logo_url")
      end

      it "returns the logo url of the partnership" do
        expect(invite.profile_picture_url).to eq("logo_url")
      end
    end

    context "when there is a user" do
      let(:partnership) { nil }
      let(:user) { create :user }

      before do
        allow(user).to receive(:profile_picture_url).and_return("profile_picture_url")
      end

      it "returns the profile picture url of the user" do
        expect(invite.profile_picture_url).to eq("profile_picture_url")
      end
    end
  end
end
