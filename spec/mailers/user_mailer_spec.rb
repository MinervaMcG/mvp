require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create :user }

  describe "sign up email" do
    let(:mail) { described_class.with(user_id: user.id).send_sign_up_email }

    it "renders the header" do
      expect(mail.subject).to eql("Confirm your email address")
      expect(mail.to).to eql([user.email])
    end

    it "assigns email verify url" do
      expect { confirm_email_url(token: user.email_confirmation_token) }.not_to raise_error
    end
  end

  describe "password reset email" do
    let(:mail) { described_class.with(user: user).send_password_reset_email }

    it "renders the header" do
      expect(mail.subject).to eql("Talent Protocol - Did you forget your password?")
      expect(mail.to).to eql([user.email])
    end

    it "assigns reset password url" do
      expect { url_for([user, :password, action: :edit, token: user.confirmation_token]) }.not_to raise_error
    end
  end

  describe "welcome email" do
    let(:mail) { described_class.with(user: user).send_welcome_email }

    it "renders the header" do
      expect(mail.subject).to eql("Welcome to the home of talented builders")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "token launch email" do
    let(:mail) { described_class.with(user: user).send_token_launched_email }

    it "renders the header" do
      expect(mail.subject).to eql("Congrats, your Talent Token is now live!")
      expect(mail.to).to eql([user.email])
    end

    it "assigns profile url" do
      expect { talent_profile_url(user.username) }.not_to raise_error
    end
  end

  describe "send complete profile reminder email" do
    let(:mail) { described_class.with(user: user).send_complete_profile_reminder_email }

    it "renders the header" do
      expect(mail.subject).to eql("Complete your profile and earn your NFT today! 🚀")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "send application received email" do
    let(:mail) { described_class.with(recipient: user).send_application_received_email }

    it "renders the header" do
      expect(mail.subject).to eql("We've received your application")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "send application rejected email" do
    let(:reviewer) { create :user }
    let(:mail) { described_class.with(recipient: user, source_id: reviewer.id).send_application_rejected_email }

    it "renders the header" do
      expect(mail.subject).to eql("Your application hasn't been approved")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "send application approved email" do
    let(:mail) { described_class.with(recipient: user).send_application_approved_email }

    it "renders the header" do
      expect(mail.subject).to eql("Hey, you can now launch your token 🚀")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "send message received email" do
    let(:sender) { create :user }
    let(:notification) { create :notification, type: "MessageReceivedNotification", recipient: user }
    let(:mail) { described_class.with(recipient: user, sender_id: sender.id, record: notification).send_message_received_email }

    before do
      allow(user).to receive(:has_unread_messages?).and_return(true)
    end

    it "renders the header" do
      expect(mail.subject).to eql("You've got a new message")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "send invite used email" do
    let(:invitee) { create :user }
    let(:notification) { create :notification, emailed_at: nil, recipient: user }

    let(:mail) do
      described_class
        .with(recipient: user, record: notification, source_id: invitee.id)
        .send_invite_used_email
    end

    it "renders the header" do
      expect(mail.subject).to eql("#{invitee.username} signed up with your invite!")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "send confirm account deletion email" do
    let(:mail) do
      described_class.with(token: "token", user: user).send_confirm_account_deletion_email
    end

    it "renders the header" do
      expect(mail.subject).to eql("Is this goodbye?")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "send goal deadline reminder email" do
    let(:mail) do
      described_class.with(goal: goal, user: user).send_goal_deadline_reminder_email
    end

    let(:goal) { create :goal, due_date: Date.current }

    it "renders the header" do
      expect(mail.subject).to eql("Your goal's deadline is today!")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "send goal half-way reminder email" do
    let(:mail) do
      described_class.with(goal: goal, user: user).send_goal_halfway_reminder_email
    end

    let(:goal) { create :goal, due_date: Date.tomorrow }

    it "renders the header" do
      expect(mail.subject).to eql("Your goal's half-way there!")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "send opportunities open roles email" do
    let(:mail) do
      described_class.with(user: user).send_opportunities_open_roles_email
    end

    it "renders the header" do
      expect(mail.subject).to eql("We have open roles for you!")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "send opportunities hiring email" do
    let(:mail) do
      described_class.with(user: user).send_opportunities_hiring_email
    end

    it "renders the header" do
      expect(mail.subject).to eql("Looking to hire talent?")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "send opportunities role landed email" do
    let(:mail) do
      described_class.with(user: user).send_opportunities_role_landed_email
    end

    it "renders the header" do
      expect(mail.subject).to eql("Did you just land a new role?")
      expect(mail.to).to eql([user.email])
    end
  end

  describe "send opportunities talent found email" do
    let(:mail) do
      described_class.with(user: user).send_opportunities_talent_found_email
    end

    it "renders the header" do
      expect(mail.subject).to eql("Did you meet talented builders?")
      expect(mail.to).to eql([user.email])
    end
  end
end
