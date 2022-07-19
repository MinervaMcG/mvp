class SendTokenLaunchReminderJob < ApplicationJob
  queue_as :default

  def perform
    users = User
      .joins(talent: :token)
      .where(token_launch_reminder_sent_at: nil)
      .where(token: {deployed: false})
      .where("talent.created_at < ?", ENV["EMAIL_REMINDER_DAYS"].to_i.days.ago)

    users.each do |user|
      UserMailer.with(user: user).send_token_launch_reminder_email.deliver_later
      user.update!(token_launch_reminder_sent_at: Time.now)
    end
  end
end
