class UserMailer < ApplicationMailer
  def send_sign_up_email
    @user_id = indifferent_access_params[:user_id]
    @user = User.find(@user_id)

    bootstrap_mail(to: @user.email, subject: "Confirm your email address")
  end

  def send_password_reset_email
    @user = indifferent_access_params[:user]
    bootstrap_mail(to: @user.email, subject: "Talent Protocol - Did you forget your password?")
  end

  def send_invite_email
    @invite = indifferent_access_params[:invite]
    @email = indifferent_access_params[:email]
    bootstrap_mail(to: @email, subject: "Talent Protocol - You're in!")
  end

  def send_welcome_email
    @user = indifferent_access_params[:user]
    bootstrap_mail(to: @user.email, subject: "Welcome to the home of talented builders")
  end

  def send_token_launch_reminder_email
    @user = indifferent_access_params[:user]
    @user.update!(token_launch_reminder_sent_at: Time.now)

    bootstrap_mail(to: @user.email, subject: "No token, no supporters 🤔")
  end

  def send_token_launched_email
    @user = indifferent_access_params[:user]
    bootstrap_mail(to: @user.email, subject: "Congrats, your Talent Token is now live!")
  end

  def send_token_purchase_reminder_email
    @user = indifferent_access_params[:user]
    @user.update!(token_purchase_reminder_sent_at: Time.now)

    bootstrap_mail(to: @user.email, subject: "You're missing out on $TAL rewards!")
  end

  def send_message_received_email
    @user = indifferent_access_params[:recipient]
    @sender = User.find(indifferent_access_params[:sender_id])
    @notification = indifferent_access_params[:record].to_notification
    @notification.record.mark_as_emailed

    set_profile_pictures_attachments([@sender])

    # we need to check if the user has unread messages
    should_sent = @user.has_unread_messages?

    bootstrap_mail(to: @user.email, subject: "You've got a new message") if should_sent
  end

  def send_complete_profile_reminder_email
    @user = indifferent_access_params[:user]
    @user.update!(complete_profile_reminder_sent_at: Time.zone.now)
    bootstrap_mail(to: @user.email, subject: "Complete your profile and earn your NFT today! 🚀")
  end

  def send_completed_profile_email
    @user = indifferent_access_params[:recipient]
    bootstrap_mail(to: @user.email, subject: "You can now apply to launch a Talent Token! 👏")
  end

  def send_digest_email
    @user = indifferent_access_params[:user]
    @without_container = true

    digest_email_sent_at = @user.digest_email_sent_at || 2.weeks.ago

    messages = Message.where(receiver: @user).where("messages.created_at > ?", digest_email_sent_at)
    messagees = User.where(id: messages.pluck(:sender_id))
    @messagee_names = messagees.map { |m| m.display_name || m.username }

    new_supporters = @user.supporters(including_self: false, invested_after: digest_email_sent_at)
    @new_supporters_names = new_supporters.map { |u| u.display_name || u.username }

    invested_in_users = @user.portfolio(including_self: false, invested_after: digest_email_sent_at).limit(3)
    @invested_in_talents = Talent.where(user: invested_in_users).includes(:user)
    set_profile_pictures_attachments(invested_in_users)

    @talents = Talent.base.active.where("talent_tokens.deployed_at > ?", 2.weeks.ago).includes(:user).limit(3)
    talent_users = User.where(id: @talents.pluck(:user_id))

    set_profile_pictures_attachments(talent_users)

    user_talent_supporters = TalentSupporter.where(supporter_wallet_id: @user.wallet_id)

    @tal_amount = user_talent_supporters.map { |t| t.tal_amount.to_i }.sum / TalentToken::TAL_DECIMALS
    @usd_amount = (@tal_amount * TalentToken::TAL_VALUE_IN_USD).round

    @user.update!(digest_email_sent_at: Time.zone.now)

    bootstrap_mail(to: @user.email, subject: "The latest on Talent Protocol")
  end

  def send_application_received_email
    @user = indifferent_access_params[:recipient]
    bootstrap_mail(to: @user.email, subject: "We've received your application")
  end

  def send_application_rejected_email
    @user = indifferent_access_params[:recipient]
    @note = indifferent_access_params[:note]
    @reviewer = User.find(indifferent_access_params[:source_id])

    bootstrap_mail(to: @user.email, subject: "Your application hasn't been approved")
  end

  def send_application_approved_email
    @user = indifferent_access_params[:recipient]
    bootstrap_mail(to: @user.email, subject: "Hey, you can now launch your token 🚀")
  end

  def send_invite_used_email
    @user = indifferent_access_params[:recipient]
    @invitee = User.find(indifferent_access_params[:source_id])
    @invitee_username = @invitee.username
    @notification = indifferent_access_params[:record].to_notification
    @notification.record.mark_as_emailed

    bootstrap_mail(to: @user.email, subject: "#{@invitee_username} signed up with your invite!")
  end

  def send_confirm_account_deletion_email
    @token = indifferent_access_params[:token]
    @user = indifferent_access_params[:user]

    bootstrap_mail(to: @user.email, subject: "Is this goodbye?")
  end

  def send_goal_deadline_reminder_email
    @goal = indifferent_access_params[:goal]
    @user = indifferent_access_params[:user]

    bootstrap_mail(to: @user.email, subject: "Your goal's deadline is today!")
  end

  def send_goal_halfway_reminder_email
    @goal = indifferent_access_params[:goal]
    @user = indifferent_access_params[:user]

    bootstrap_mail(to: @user.email, subject: "Your goal's half-way there!")
  end

  def send_opportunities_open_roles_email
    @user = indifferent_access_params[:user]

    bootstrap_mail(to: @user.email, subject: "We have open roles for you!")
  end

  def send_opportunities_hiring_email
    @user = indifferent_access_params[:user]

    bootstrap_mail(to: @user.email, subject: "Looking to hire talent?")
  end

  def send_opportunities_role_landed_email
    @user = indifferent_access_params[:user]

    bootstrap_mail(to: @user.email, subject: "Did you just land a new role?")
  end

  def send_opportunities_talent_found_email
    @user = indifferent_access_params[:user]

    bootstrap_mail(to: @user.email, subject: "Did you meet talented builders?")
  end

  private

  def indifferent_access_params
    @indifferent_access_params ||= params.with_indifferent_access
  end

  def set_profile_pictures_attachments(users)
    users.each do |user|
      attachments.inline["profile_picture-#{user.id}.png"] = Down.download(user.profile_picture_url).read
    end
  rescue => e
    Rollbar.error(e, "Error downloading picture of users: ##{users.map(&:id).join(", ")}")
  end
end
