require "rails_helper"

RSpec.describe API::UpdateTalent do
  let(:talent) { create :talent, :full_profile, :with_career_goal, public: false }
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
    let(:career_needs_params) { {} }

    it "the talent becomes public" do
      update_talent.call(talent_params, user_params, tag_params, career_needs_params)

      expect(user.talent.public).to eq true
    end
  end

  context "when there are career need params" do
    let(:talent_params) { {} }
    let(:user_params) { {} }
    let(:tag_params) { {} }
    let(:career_needs_params) { {career_needs: ["Full-time roles"]} }

    let(:career_needs_upsert_class) { CareerNeeds::Upsert }
    let(:career_needs_upsert) { instance_double(career_needs_upsert_class, call: true) }

    before do
      allow(career_needs_upsert_class).to receive(:new).and_return(career_needs_upsert)
    end

    it "initialises and calls the career needs upsert class with the correct arguments" do
      update_talent.call(talent_params, user_params, tag_params, career_needs_params)

      aggregate_failures do
        expect(career_needs_upsert_class)
          .to have_received(:new)
          .with(career_goal: talent.career_goal, titles: career_needs_params[:career_needs])

        expect(career_needs_upsert).to have_received(:call)
      end
    end
  end
end
