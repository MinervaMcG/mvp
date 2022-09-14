require "rails_helper"

RSpec.describe EmailReminders::SendGoalDeadlineReminderJob, type: :job do
  include ActiveJob::TestHelper

  let(:goal_one) { create :goal, due_date: Date.yesterday }
  let!(:user_one) { create :user, talent: goal_one.career_goal.talent }

  let(:goal_two) { create :goal, due_date: Date.current }
  let!(:user_two) { create :user, talent: goal_two.career_goal.talent }

  let(:goal_three) { create :goal, due_date: Date.tomorrow }
  let!(:user_three) { create :user, talent: goal_three.career_goal.talent }

  describe "#perform" do
    subject(:send_goal_deadline_reminder_email) { described_class.perform_now }

    it "sends a reminder email to users with goals due today" do
      Sidekiq::Testing.inline! do
        send_goal_deadline_reminder_email

        perform_enqueued_jobs

        deliveries = ActionMailer::Base.deliveries

        aggregate_failures do
          expect(deliveries.count).to eq(1)
          expect(deliveries.first.subject).to eq("Your goal's deadline is today!")
        end
      end
    end
  end
end
