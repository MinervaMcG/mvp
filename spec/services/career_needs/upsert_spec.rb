require "rails_helper"

RSpec.describe CareerNeeds::Upsert do
  include ActiveJob::TestHelper

  let(:career_goal) { create :career_goal }
  let(:titles) { ["Internships"] }

  subject(:upsert_career_needs) do
    described_class.new(career_goal: career_goal, titles: titles)
  end

  describe "#call" do
    it "creates the career need" do
      expect { subject.call }.to change { CareerNeed.count }.by(1)

      career_need = CareerNeed.last

      aggregate_failures do
        expect(career_need.career_goal).to eq(career_goal)
        expect(career_need.title).to eq("Internships")
      end
    end

    context "when the career need exists for the career goal already" do
      let!(:career_need) do
        create :career_need, career_goal: career_goal, title: "Internships"
      end

      it "does not create the career need" do
        expect { subject.call }.not_to change(CareerNeed, :count)
      end
    end

    context "when the career goal has a career need that is not included in the passed titles" do
      let!(:career_need) do
        create :career_need, career_goal: career_goal, title: "Finding a co-founder"
      end

      it "destroy the career need" do
        subject.call

        expect(CareerNeed.exists?(career_need.id)).to eq(false)
      end
    end
  end
end
