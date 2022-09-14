module Users
  class CreateDeleteAccountToken
    def initialize(user:)
      @user = user
    end

    def call
      if user.update(delete_account_token_attributes)
        send_confirm_account_deletion_email
        {success: true}
      else
        {success: false}
      end
    end

    private

    attr_reader :user

    def delete_account_token_attributes
      {
        delete_account_token: token,
        delete_account_token_expires_at: Time.current + 1.hour
      }
    end

    def token
      @token ||= SecureRandom.hex
    end

    def send_confirm_account_deletion_email
      UserMailer
        .with(token: token, user: user)
        .send_confirm_account_deletion_email
        .deliver_later
    end
  end
end
