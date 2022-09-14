module Stakes
  class Create
    def initialize(talent_token:, staking_user:)
      @talent_token = talent_token
      @staking_user = staking_user
    end

    def call
      if !staking_user.tokens_purchased
        staking_user.update!(tokens_purchased: true)
        AddUsersToMailerliteJob.perform_later(staking_user.id)
        SendMemberNFTToUserJob.perform_later(user_id: staking_user.id)
        UpdateTasksJob.perform_later(type: "Tasks::BuyTalentToken", user_id: staking_user.id)
      end

      if !staking_own_token?
        CreateNotification.new.call(
          recipient: talent_token.talent.user,
          type: TokenAcquiredNotification,
          source_id: staking_user.id,
          extra_params: extra_params
        )
      end

      TalentSupportersRefreshJob.perform_later(talent_token.contract_id)
    end

    private

    attr_reader :talent_token, :staking_user

    def staking_own_token?
      talent_token.talent.user_id == staking_user.id
    end

    def extra_params
      return {} unless reinvestment?

      {reinvestment: true}
    end

    def reinvestment?
      TalentSupporter.where(supporter_wallet_id: staking_user.wallet_id, talent_contract_id: talent_token.contract_id).exists?
    end
  end
end
