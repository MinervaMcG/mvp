require "rails_helper"

RSpec.describe API::UpdateTalent do
  let(:talent) { create :talent, :full_profile, public: false }
  let(:user) { create :user, talent: talent }
  let(:quest) { create :quest, user: user }
  subject(:update_talent) { described_class.new(user.talent, user) }

  before do
    create :task, quest: quest, type: "Tasks::ApplyTokenLaunch"
  end

  context "when the user is approved" do
    let(:user_params) { {profile_type: "approved"} }
    let(:talent_params) { {} }
    let(:tag_params) { {} }

    it "the talent becomes public" do
      update_talent.call(talent_params, user_params, tag_params)

      expect(user.talent.public).to eq true
    end
  end
end
