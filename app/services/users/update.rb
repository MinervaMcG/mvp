module Users
  class Update
    def initialize(user:, user_params:, password_params:, tal_domain:, wallet_id:, first_quest_popup:)
      @user = user
      @user_params = user_params
      @password_params = password_params
      @tal_domain = tal_domain
      @wallet_id = wallet_id
      @first_quest_popup = first_quest_popup
    end

    def call
      update_wallet! if wallet_id

      user.update!(first_quest_popup: true) if first_quest_popup

      if new_tal_domain?
        if ens_domain_owner.nil? || ens_domain_owner&.downcase != user.wallet_id
          return {success: false, errors: {talDomain: "Your wallet does not own the domain specified"}}
        end
        update_tal_domain
      end

      if user_params.any?
        # username should always match the invite code
        if !!user_params[:username] && user_params[:username] != user.username
          invite = Invite.find_by(code: user.username)
          invite&.update(code: user_params[:username])
        end

        if !!user_params[:username] && !User.valid_username?(user_params[:username])
          return {success: false, errors: {username: "Username only allows lower case letters and numbers"}}
        end

        if !!user_params[:email] && !User.valid_email?(user_params[:email])
          return {success: false, errors: {email: "Email is not valid"}}
        end

        user.update!(user_params)

        if !!user_params[:email]
          user.update!(confirmation_token: Clearance::Token.new)
        end
      end

      if password_params[:new_password]&.length&.positive?
        if user.authenticated?(password_params[:current_password])
          user.update!(password: password_params[:new_password])
        else
          return {success: false, errors: {currentPassword: "Passwords don't match"}}
        end
      end

      {success: true, user: user}
    rescue ActiveRecord::RecordNotUnique => e
      if e.to_s.include?("username")
        {success: false, errors: {username: "Username is taken"}}
      elsif e.to_s.include?("email")
        {success: false, errors: {email: "Email is taken"}}
      else
        {success: false, errors: "Wallet already exists in the system"}
      end
    rescue ActiveRecord::RecordInvalid
      {success: false, errors: "Wallet already exists in the system"}
    end

    private

    attr_reader :user, :user_params, :password_params, :tal_domain, :wallet_id, :first_quest_popup

    def update_wallet!
      user.update!(wallet_id: wallet_id&.downcase)

      AddUsersToMailerliteJob.perform_later(user.id)
      UpdateTasksJob.perform_later(type: "Tasks::ConnectWallet", user_id: user.id)
      Web3::RefreshDomains.new(user: user).call
    end

    def new_tal_domain?
      tal_domain.present? && tal_domain != user.tal_domain&.domain
    end

    def update_tal_domain
      user_domain = UserDomain.find_or_initialize_by(
        user: user,
        tal_domain: true,
        provider: "ens",
        chain_id: domain_chain_id
      )
      user_domain.update!(domain: tal_domain, wallet: user.wallet_id)
    end

    def ens_domain_owner
      @ens_domain_owner ||= Web3::EnsDomainOwner.new(domain: tal_domain).call
    end

    def domain_chain_id
      # 1 mainnet
      # 5 goerli
      (ENV["CONTRACTS_ENV"] == "production") ? 1 : 5
    end
  end
end
