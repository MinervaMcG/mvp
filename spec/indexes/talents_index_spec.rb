require "rails_helper"

RSpec.describe TalentsIndex do
  let(:talent1) { create :talent, verified: true }
  let(:talent2) { create :talent, verified: true }

  describe "Update talents" do
    it "should index the talent attributes" do
      expect do
        talent1.update_attribute(:verified, false)
      end.to update_index(TalentsIndex).and_reindex(talent1)
    end

    it "should delete the talent" do
      expect { talent2.destroy! }.to update_index(TalentsIndex).and_delete(talent2)
    end
  end

  describe "User update" do
    let(:user1) { create(:user) }

    before { talent1.user = user1 }

    it "should index the new talent user" do
      expect { talent1.save! }.to update_index(TalentsIndex).and_reindex(talent1)
    end

    it "should update the talent user" do
      expect { talent1.user.update_attribute(:legal_first_name, "Test") }.to update_index(TalentsIndex).and_reindex(talent1, with: {user: {legal_first_name: "Test"}})
    end

    it "should add the talent user tags" do
      expect do
        talent1.user.tags << Tag.new(description: "Test")
        talent1.save!
      end.to update_index(TalentsIndex).and_reindex(talent1, with: {user: {tags: ["Test"]}})
    end
  end

  describe "Talent token update" do
    let(:talent_token) { create(:talent_token) }

    before { talent1.talent_token = talent_token }

    it "should index the new talent token" do
      expect { talent1.save! }.to update_index(TalentsIndex).and_reindex(talent1)
    end

    it "should update the talent user" do
      expect { talent1.talent_token.update_attribute(:ticker, "Test") }.to update_index(TalentsIndex).and_reindex(talent1, with: {talent_token: {ticker: "Test"}})
    end
  end

  describe "Milestones update" do
    let(:milestone1) { create(:milestone) }
    let(:milestone2) { create(:milestone) }

    before do
      talent1.milestones << milestone1
      talent1.milestones << milestone2
    end

    it "should index the new milestones" do
      expect { talent1.save! }.to update_index(TalentsIndex).and_reindex(talent1)
    end

    it "should update the milestones" do
      expect do
        talent1.milestones.map { |m, i| m.update_attribute(:title, "Test#{i}") }
      end.to update_index(TalentsIndex).and_reindex(talent1)
    end
  end

  describe "CareerGoal update" do
    let(:career_goal) { create(:career_goal, goals: [goal1, goal2]) }
    let(:goal1) { create(:goal, due_date: Time.zone.today + 10.days) }
    let(:goal2) { create(:goal, due_date: Time.zone.today + 15.days) }

    before { talent1.career_goal = career_goal }

    it "should index the new career goal" do
      expect { talent1.save! }.to update_index(TalentsIndex).and_reindex(talent1)
    end

    it "should update the career goal" do
      expect { talent1.career_goal.update_attribute(:description, "Test") }.to update_index(TalentsIndex).and_reindex(talent1, with: {career_goal: {description: "Test"}})
    end
  end
end
