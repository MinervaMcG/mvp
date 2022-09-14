require "rails_helper"

RSpec.describe SetupNextRaceJob, type: :job do
  let!(:next_race) { create :race, started_at: Date.yesterday + 1.week, ends_at: Date.yesterday + 2.week }
  let!(:current_race) { create :race, started_at: Date.yesterday, ends_at: Date.yesterday + 1.week }

  let(:winners) { create_list :user, 5 }

  subject(:setup_new_race) { SetupNextRaceJob.perform_now }

  before do
    allow(current_race).to receive(:results).and_return(winners)
  end

  it "creates a new race" do
    expect { setup_new_race }.to change(Race, :count).from(2).to(3)
  end
end
