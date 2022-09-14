module EmailReminders
  class SendGoalDeadlineReminderJob < ApplicationJob
    queue_as :default

    def perform
      Goal.due_today.find_each do |goal|
        UserMailer
          .with(goal: goal, user: goal.career_goal.talent.user)
          .send_goal_deadline_reminder_email
          .deliver_later
      end
    end
  end
end
