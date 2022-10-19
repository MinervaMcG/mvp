module Users
  class Create
    attr_reader :result

    def initialize
      @result = {}
    end

    def call(params)
      ActiveRecord::Base.transaction do
        invite = Invite.find_by(code: params[:invite_code])
        invite&.update(uses: invite.uses + 1)
        params[:invite] = invite if invite
        user = create_user(params)

        create_investor(user)
        create_feed(user)
        create_talent(user)
        create_talent_token(user)
        create_invite_used_notification(invite, user) if invite

        if invite&.talent_invite?
          update_profile_type(user, invite)
          upsert_discovery_row(invite, user) if invite.partnership.present?
        end

        create_invite(user)
        create_tasks(user)
        create_follow(invite, user)

        UserMailer.with(user: user).send_welcome_email.deliver_later(wait: 5.seconds)

        @result[:user] = user
        @result[:success] = true
        @result
      rescue ActiveRecord::RecordNotUnique => error
        @result[:success] = false
        if error.message.include?("username")
          @result[:field] = "username"
          @result[:error] = "Username is already taken."
        elsif error.message.include?("email")
          @result[:field] = "email"
          @result[:error] = "Email is already taken."
        elsif error.message.include?("wallet_id")
          @result[:field] = "wallet_id"
          @result[:error] = "We already have that wallet in the system."
        end
        @result
      rescue => e
        Rollbar.error(
          e,
          "Unable to create user with unexpected error.",
          email: params[:email],
          username: params[:username]
        )

        raise e
      end
    end

    private

    def create_user(params)
      user = User.new(attributes(params))
      user.save!
      user
    end

    def attributes(params)
      {
        display_name: params[:display_name],
        email_confirmation_token: Clearance::Token.new,
        email: params[:email].downcase,
        invited: params[:invite],
        linkedin_id: params[:linkedin_id],
        password: params[:password],
        role: "basic",
        theme_preference: params[:theme_preference],
        legal_first_name: params[:legal_first_name],
        legal_last_name: params[:legal_last_name],
        username: params[:username].downcase.delete(" ", "")
      }.compact
    end

    def create_talent(user)
      user.create_talent!
      user.talent.create_career_goal!
    end

    def create_talent_token(user)
      user.talent.create_talent_token!
    end

    def upsert_discovery_row(invite, user)
      partnership = invite.partnership

      discovery_row = partnership.discovery_row
      discovery_row ||= DiscoveryRow.create!(
        partnership: partnership,
        title: partnership.name,
        description: partnership.description
      )

      tag = Tag.find_by(description: invite.code, hidden: true)
      tag ||= Tag.create!(description: invite.code, hidden: true)

      discovery_row.tags << tag unless discovery_row.tags.include?(tag)
      user.tags << tag unless user.tags.include?(tag)
    end

    def create_investor(user)
      investor = Investor.new
      investor.user = user
      investor.save!
      investor
    end

    def create_feed(user)
      feed = Feed.create!(user: user)

      admin = User.find_by(email: "admin@talentprotocol.com")
      if admin.present?
        admin.posts.find_each do |post|
          feed.posts << post
        end
      end
      feed
    end

    def create_invite(user)
      service = Invites::Create.new(user_id: user.id)

      service.call
    end

    def create_tasks(user)
      Tasks::PopulateForUser.new.call(user: user)
      Tasks::Update.new.call(type: "Tasks::ApplyTokenLaunch", user: user)
    end

    def create_invite_used_notification(invite, user)
      inviter = invite.user
      return unless inviter

      CreateNotification.new.call(recipient: inviter, source_id: user.id, type: InviteUsedNotification)
    end

    def update_profile_type(user, invite)
      Users::UpdateProfileType.new.call(user: user, who_dunnit_id: invite.user_id, new_profile_type: "talent")
      user.reload
    end

    def create_follow(invite, user)
      return if invite.nil?

      invited_by_user = invite.user
      follow = Follow.find_or_initialize_by(user_id: user.id, follower_id: invited_by_user.id)
      unless follow.persisted? # validate if the watchlist quest is completed
        UpdateTasksJob.perform_later(type: "Tasks::Watchlist", user_id: invited_by_user.id)
      end
    end
  end
end
