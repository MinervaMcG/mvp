require "with_persona/client"

module WithPersona
  class ApproveInquiry
    def initialize(talent:, inquiry_first_name:, inquiry_last_name:)
      @talent = talent
      @inquiry_first_name = inquiry_first_name&.downcase
      @inquiry_last_name = inquiry_last_name&.downcase
    end

    def call
      if names_match?
        talent.update(verified: true)
        Tasks::Update.new.call(type: "Tasks::Verified", user: user)
      else
        with_persona_id = talent.with_persona_id
        talent.update(with_persona_id: nil)

        CreateNotification.new.call(
          recipient: user,
          source_id: user.id,
          type: UserNamesVerificationFailedNotification,
          extra_params: {reason: "name", with_persona_id: with_persona_id}
        )
      end
    end

    private

    attr_reader :talent, :inquiry_first_name, :inquiry_last_name

    def user
      @user ||= talent.user
    end

    def names_match?
      user.legal_first_name && user.legal_last_name && inquiry_first_name.include?(user.legal_first_name&.downcase) && inquiry_last_name.include?(user.legal_last_name&.downcase)
    end
  end
end
