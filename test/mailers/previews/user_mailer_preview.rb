# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def send_sign_up_email
    UserMailer.with(user_id: User.first.id).send_sign_up_email
  end

  def send_welcome_email
    UserMailer.with(user: User.first).send_welcome_email
  end

  def send_token_purchase_reminder_email
    UserMailer.with(user: User.first).send_token_purchase_reminder_email
  end

  def send_password_reset_email
    UserMailer.with(user: User.first).send_password_reset_email
  end

  def send_token_launched_email
    UserMailer.with(user: User.first).send_token_launched_email
  end

  def send_message_received_email
    recipient = User.first
    sender_id = User.second.id
    notification = Notification.create(
      type: "MessageReceivedNotification",
      params: {
        "sender_id" => sender_id
      },
      recipient: recipient
    )
    UserMailer.with(recipient: recipient, record: notification, sender_id: sender_id).send_message_received_email
  end

  def send_complete_profile_reminder_email
    UserMailer.with(user: User.first).send_complete_profile_reminder_email
  end

  def send_completed_profile_email
    UserMailer.with(user: User.first).send_completed_profile_email
  end

  def send_digest_email
    UserMailer.with(user: User.last).send_digest_email
  end

  def send_application_received_email
    UserMailer.with(user: User.last).send_application_received_email
  end

  def send_application_rejected_email
    UserMailer.with(user: User.last).send_application_rejected_email
  end

  def send_application_approved_email
    UserMailer.with(user: User.first).send_application_approved_email
  end

  def send_invite_used_email
    recipient = User.first
    source_id = User.second.id

    notification = Notification.create(
      params: {"source_id" => source_id},
      recipient: recipient,
      type: "InviteUsedNotification"
    )

    UserMailer
      .with(recipient: recipient, record: notification, source_id: source_id)
      .send_invite_used_email
  end

  def send_confirm_account_deletion_email
    user = User.first
    user.update(profile_type: "talent")

    UserMailer.with(token: "token", user: user).send_confirm_account_deletion_email
  end

  def send_goal_deadline_reminder_email
    user = User.first

    UserMailer.with(goal: goal(user), user: user).send_goal_deadline_reminder_email
  end

  def send_goal_halfway_reminder_email
    user = User.first

    UserMailer.with(goal: goal(user), user: user).send_goal_halfway_reminder_email
  end

  private

  def goal(user)
    talent = user.talent || user.create_talent!
    career_goal = talent.career_goal || talent.create_career_goal!
    career_goal.goals.first || career_goal.goals.create!(due_date: Date.current, title: "New Goal")
  end
end
