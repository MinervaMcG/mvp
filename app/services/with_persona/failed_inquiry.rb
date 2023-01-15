require "with_persona/client"

module WithPersona
  class FailedInquiry
    def initialize(talent:)
      @talent = talent
    end

    def call
      with_persona_id = talent.with_persona_id
      talent.update(with_persona_id: nil)

      CreateNotification.new.call(
        recipient: user,
        source_id: user.id,
        type: UserPersonaVerificationFailedNotification,
        extra_params: {reason: "with_persona", with_persona_id: with_persona_id}
      )
    end

    private

    attr_reader :talent

    def user
      @user ||= talent.user
    end
  end
end
