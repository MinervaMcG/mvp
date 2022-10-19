class TalentApplicationRejectedNotification < BaseNotification
  deliver_by :email, mailer: "UserMailer", method: :send_application_rejected_email, delay: 15.minutes, if: :should_deliver_immediate_email?

  def url
    profile_url(username: recipient.username)
  end
end
