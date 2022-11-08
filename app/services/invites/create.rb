module Invites
  class Create
    MAX_RETRIES = 5

    def initialize(params)
      @max_uses = params.fetch(:max_uses, nil)
      @partnership = params.fetch(:partnership, nil)
      @talent_invite = params.fetch(:talent_invite, false)
      @user = params.fetch(:user, nil)
    end

    def call
      invite = existing_invite
      return invite if invite

      invite = Invite.new
      invite.partnership = partnership
      invite.max_uses = max_uses
      invite.talent_invite = talent_invite
      invite.user = user

      count = 0

      begin
        invite.code = code(invite)
        invite.save!
      rescue ActiveRecord::RecordNotUnique
        count += 1
        retry if count <= MAX_RETRIES
      end

      invite
    end

    private

    attr_reader :max_uses, :partnership, :talent_invite, :user

    def existing_invite
      record = partnership || user
      return unless record

      record.invites.find_by(talent_invite: talent_invite)
    end

    def code(invite)
      return user.username if user && Invite.where(code: user.username).empty?

      "#{prefix(invite)}-#{Invite.generate_code}"
    end

    def prefix(invite)
      invite.talent_invite ? "TAL" : "SUP"
    end
  end
end
