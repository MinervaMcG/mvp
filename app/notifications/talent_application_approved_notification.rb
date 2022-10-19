class TalentApplicationApprovedNotification < BaseNotification
  deliver_by :email, mailer: "UserMailer", method: :send_application_approved_email, delay: 15.minutes, if: :should_deliver_immediate_email?

  def url
    profile_url(username: recipient.username, tab: "Token")
  end
end
