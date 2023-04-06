require "rails_helper"

RSpec.describe CareerUpdates::Create do
  let(:sender) { create :user }
  let(:message) { "Career update!" }

  subject(:create_career_update) do
    described_class.new(sender: sender, message: message).call
  end

  describe "#call" do
    it "creates the career update" do
      expect { create_career_update }.to change { CareerUpdate.count }.by(1)

      career_need = CareerUpdate.last

      aggregate_failures do
        expect(career_need.text).to eq(message)
        expect(career_need.user).to eq(sender)
      end
    end

    it "enqueues a job to broadcast the update" do
      expect { create_career_update }.to have_enqueued_job(BroadcastCareerUpdateJob)
    end
  end
end