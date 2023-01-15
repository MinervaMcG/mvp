require "rails_helper"

RSpec.describe Users::Destroy do
  subject(:destroy_user) { described_class.new(user: user).call }

  let!(:user) { create :user }

  it "destroys the user" do
    expect { destroy_user }.to change(User, :count).from(1).to(0)
  end

  context "when the user has talent relations" do
    let!(:talent) { create :talent, user: user }
    let!(:talent_token) { create :talent_token, talent: talent, contract_id: nil }
    let!(:career_goal) { create :career_goal, talent: talent }
    let!(:goal) { create :goal, career_goal: career_goal, title: "Test", due_date: Date.tomorrow }
    let!(:career_need) { create :career_need, career_goal: career_goal, title: "Test" }
    let!(:milestone) { create :milestone, talent: talent }
    let!(:perk) { create :perk, talent: talent, title: "Test" }

    it "returns the destroyed user" do
      expect(destroy_user).to eq user
    end

    it "destroys the relations" do
      destroy_user

      expect(User.count).to eq 0
      expect(Talent.count).to eq 0
      expect(TalentToken.count).to eq 0
      expect(CareerGoal.count).to eq 0
      expect(CareerNeed.count).to eq 0
      expect(Goal.count).to eq 0
      expect(Milestone.count).to eq 0
      expect(Perk.count).to eq 0
    end
  end
end
