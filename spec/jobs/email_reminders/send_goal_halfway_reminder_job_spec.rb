require "rails_helper"

RSpec.describe EmailReminders::SendGoalHalfwayReminderJob, type: :job do
  include ActiveJob::TestHelper

  let(:goal_one) { create :goal, created_at: "2022-01-03", due_date: "2022-01-06" }
  let!(:user_one) { create :user, talent: goal_one.career_goal.talent }

  let(:goal_two) { create :goal, created_at: "2022-01-04", due_date: "2022-01-06" }
  let!(:user_two) { create :user, talent: goal_two.career_goal.talent }

  let(:goal_three) { create :goal, created_at: "2022-01-04", due_date: "2022-01-07" }
  let!(:user_three) { create :user, talent: goal_three.career_goal.talent }

  describe "#perform" do
    subject(:send_goal_halfway_reminder_email) { described_class.perform_now }

    it "sends a reminder email to users with goals that are half-way" do
      travel_to("2022-01-06") do
        Sidekiq::Testing.inline! do
          send_goal_halfway_reminder_email

          perform_enqueued_jobs

          deliveries = ActionMailer::Base.deliveries

          aggregate_failures do
            expect(deliveries.count).to eq(2)
            expect(deliveries.first.subject).to eq("Your goal's half-way there!")
          end
        end
      end
    end
  end
end
