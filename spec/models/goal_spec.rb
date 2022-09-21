require "rails_helper"

RSpec.describe Goal, type: :model do
  describe ".due_halfway" do
    let!(:goal_one) { create :goal, created_at: "2022-01-03", due_date: "2022-01-06" }
    let!(:goal_two) { create :goal, created_at: "2022-01-04", due_date: "2022-01-06" }
    let!(:goal_three) { create :goal, created_at: "2022-01-04", due_date: "2022-01-07" }
    let!(:goal_four) { create :goal, created_at: "2022-01-05", due_date: "2022-01-05" }
    let!(:goal_five) { create :goal, created_at: "2022-01-06", due_date: "2022-01-10" }

    it "returns the goals that are half-way due" do
      travel_to("2022-01-06") do
        expect(described_class.due_halfway).to match_array([goal_one, goal_two, goal_four])
      end

      travel_to("2022-01-07") do
        expect(described_class.due_halfway).to match_array([goal_three])
      end

      travel_to("2022-01-09") do
        expect(described_class.due_halfway).to match_array([goal_five])
      end
    end
  end

  describe ".due_today" do
    let!(:goal_one) { create :goal, due_date: Date.tomorrow }
    let!(:goal_two) { create :goal, due_date: Date.current }
    let!(:goal_three) { create :goal, due_date: Date.yesterday }

    it "returns the goals that are due today" do
      expect(described_class.due_today).to eq([goal_two])
    end
  end
end
