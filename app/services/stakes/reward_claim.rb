module Stakes
  class RewardClaim
    def initialize(token:)
      @token = token
    end

    def call
      TalentSupportersRefreshJob.perform_later(token.contract_id)
    end

    private

    attr_reader :token
  end
end
