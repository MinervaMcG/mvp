require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_one(:talent) }
    it { is_expected.to have_one(:user_email_log) }

    # Chat
    it { is_expected.to have_many(:messagee) }
    it { is_expected.to have_many(:senders).through(:messagee) }
    it { is_expected.to have_many(:messaged) }
    it { is_expected.to have_many(:receivers).through(:messaged) }

    # Feed
    it { is_expected.to have_one(:feed) }
    it { is_expected.to have_many(:follows) }
    it { is_expected.to have_many(:followers).through(:follows) }
    it { is_expected.to have_many(:following) }
    it { is_expected.to have_many(:comments) }
    it { is_expected.to have_many(:posts) }
    it { is_expected.to have_many(:connections) }
  end

  describe "email_and_credentials validation" do
    context "when the user does not have an email" do
      it "raises a RecordInvalid error" do
        expect { create :user, email: "" }
          .to raise_error(
            ActiveRecord::RecordInvalid,
            "Validation failed: The user doesn't respect the required login requirements"
          )
      end
    end

    context "when the user has an email" do
      context "when the user has a password but no LinkedIn id" do
        it "does not raise an error" do
          expect { create :user, linkedin_id: nil }.not_to raise_error
        end
      end

      context "when the user has a LinkedIn id but no password" do
        it "does not raise an error" do
          expect { create :user, linkedin_id: "user_132298", password: nil }.not_to raise_error
        end
      end

      context "when the user does not have a password or LinkedIn id" do
        it "raises a RecordInvalid error" do
          expect { create :user, linkedin_id: nil, password: nil }
            .to raise_error(
              ActiveRecord::RecordInvalid,
              "Validation failed: The user doesn't respect the required login requirements"
            )
        end
      end
    end
  end

  describe "uniqueness validation" do
    it "does not allow multiple users with same email" do
      create(:user, email: "john.doe@talentprotocol.com")

      expect {
        create(:user, email: "john.doe@talentprotocol.com")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "does not allow multiple users with same username" do
      create(:user, username: "frank")

      expect {
        create(:user, username: "frank")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "does not allow multiple users with same wallet_id" do
      create(:user, wallet_id: "1")

      expect {
        create(:user, wallet_id: "1")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "does not allow non supported roles" do
      expect {
        create(:user, role: "Investor")
      }.to raise_error(ActiveRecord::RecordInvalid).with_message(/The role Investor isn't supported./)
    end
  end

  describe "helper methods" do
    it "calculates the correct chat id" do
      user1 = create(:user, wallet_id: "0", username: "0")
      user2 = create(:user, wallet_id: "1", username: "1")

      expect(user1.sender_chat_id(user2)).to eq(user1.id.to_s + user2.id.to_s)
      expect(user1.receiver_chat_id(user2)).to eq(user1.id.to_s + user2.id.to_s)
    end

    it "calculates the correct last message sent between two users" do
      user1 = create(:user, wallet_id: "0", username: "0")
      user2 = create(:user, wallet_id: "1", username: "1")
      create(:message, sender: user1, receiver: user2, text: "Hello!")
      create(:message, sender: user1, receiver: user2, text: "Bye!")

      expect(user1.last_message_with(user2).text).to eq("Bye!")
    end

    it "checks if user has unread messages" do
      user1 = build(:user, email: "a@m.com")
      user2 = build(:user, email: "b@m.com")
      create(:message, sender: user1, receiver: user2, text: "Hello!",
                       is_read: true)
      create(:message, sender: user2, receiver: user1, text: "Hello!",
                       is_read: false)
      create(:message, sender: user2, receiver: user1, text: "Bye!", is_read:
             false)

      expect(user1.has_unread_messages?).to be_truthy
      expect(user2.has_unread_messages?).to be_falsey
    end
  end

  describe ".beginner_quest_completed" do
    let(:user_1) { create :user }
    let(:user_2) { create :user }
    let(:user_3) { create :user }

    before do
      create :quest, type: "Quests::User", status: "done", user: user_1
      create :quest, type: "Quests::Scout", status: "done", user: user_3
      create :quest, type: "Quests::User", status: "pending", user: user_3
    end

    it "only returns users with the beginner quest completed" do
      expect(User.beginner_quest_completed).to eq [user_1]
    end
  end

  describe "#admin_or_moderator?" do
    let(:user) { create :user, role: role }

    context "when the user's role is 'admin'" do
      let(:role) { "admin" }

      it "returns false" do
        expect(user.admin_or_moderator?).to be_truthy
      end
    end

    context "when the user's role is 'basic'" do
      let(:role) { "basic" }

      it "returns false" do
        expect(user.admin_or_moderator?).to be_falsey
      end
    end

    context "when the user's role is 'moderator'" do
      let(:role) { "moderator" }

      it "returns true" do
        expect(user.admin_or_moderator?).to be_truthy
      end
    end
  end

  describe "#amount_invested_in" do
    let(:user) { create :user }

    let(:other_user) { create :user, talent: talent }
    let(:talent) { create :talent }
    let(:talent_token) { create :talent_token, talent: talent, deployed: true }

    context "when the user does not have an investment in the other user" do
      it "returns 0" do
        expect(user.amount_invested_in(other_user)).to eq 0
      end
    end

    context "when the user has an investment in the other user" do
      before do
        create :talent_supporter, supporter_wallet_id: user.wallet_id, talent_contract_id: talent_token.contract_id, amount: "1000000"
      end

      it "returns the amount invested by the user" do
        expect(user.amount_invested_in(other_user)).to eq 1000000
      end
    end
  end

  describe "#approved_by" do
    let(:user) { create :user, profile_type: profile_type }
    let(:who_dunnit) { create :user, role: "admin" }

    context "when the user's profile type is 'approved'" do
      let(:profile_type) { "approved" }

      context "when there is a profile type change log for the change" do
        before do
          UserProfileTypeChange.create!(
            previous_profile_type: "waiting_for_approval",
            new_profile_type: "approved",
            user: user,
            who_dunnit: who_dunnit
          )
        end

        it "returns the user who approved it" do
          expect(user.approved_by).to eq(who_dunnit)
        end
      end

      context "when there is not a profile type change log for the change" do
        before do
          UserProfileTypeChange.create!(
            previous_profile_type: "supporter",
            new_profile_type: "talent",
            user: user,
            who_dunnit: who_dunnit
          )
        end

        it "returns nil" do
          expect(user.approved_by).to be_nil
        end
      end
    end

    context "when the user's profile type is not 'approved'" do
      let(:profile_type) { "rejected" }

      it "returns nil" do
        expect(user.approved_by).to be_nil
      end
    end
  end

  describe "#beginner_quest_completed?" do
    let(:user) { create :user }

    before do
      create :quest, type: "Quests::User", status: quest_status, user: user
    end

    context "when the quest status is done" do
      let(:quest_status) { "done" }

      it "returns true" do
        expect(user.beginner_quest_completed?).to eq true
      end
    end

    context "when the quest status is not done" do
      let(:quest_status) { "pending" }

      it "returns false" do
        expect(user.beginner_quest_completed?).to eq false
      end
    end
  end

  describe "#display_wallet_id?" do
    let(:user) { create :user, wallet_id: "0x123456789101234567890" }

    context "when a user domain is associated with the user" do
      before do
        create :user_domain, domain: "dinis.blockchain", user: user
      end

      it "returns the domain" do
        expect(user.display_wallet_id).to eq("dinis.blockchain")
      end
    end

    context "when a user domain is not associated with the user" do
      it "shortens the wallet id for displaying" do
        expect(user.display_wallet_id).to eq("0x123456789...")
      end
    end
  end

  describe "#supporters" do
    let(:user) { create :user, talent: talent }
    let(:talent) { create :talent }
    let(:talent_token) { create :talent_token, talent: talent, deployed: true }

    context "when the user does not have any supporter" do
      it "returns an empty array" do
        expect(user.supporters).to be_empty
      end
    end

    context "when the user has some supporters" do
      let(:supporter_one) { create :user }
      let(:supporter_two) { create :user }
      let(:supporter_three) { create :user }

      before do
        create :talent_supporter, supporter_wallet_id: supporter_one.wallet_id, talent_contract_id: talent_token.contract_id, last_time_bought_at: Date.today - 10.days
        create :talent_supporter, supporter_wallet_id: supporter_two.wallet_id, talent_contract_id: talent_token.contract_id, last_time_bought_at: Date.today - 5.days
        create :talent_supporter, supporter_wallet_id: supporter_three.wallet_id, talent_contract_id: SecureRandom.hex, last_time_bought_at: Date.today - 2.days
        create :talent_supporter, supporter_wallet_id: user.wallet_id, talent_contract_id: talent_token.contract_id, last_time_bought_at: Date.today
      end

      it "returns the users that support him" do
        expect(user.supporters).to match_array([user, supporter_one, supporter_two])
      end

      context "when including_self is passed as false" do
        it "returns the users that support him expect himself" do
          expect(user.supporters(including_self: false)).to match_array([supporter_one, supporter_two])
        end
      end

      context "when invested_after is passed" do
        let(:date) { Date.today - 6.days }

        it "returns the supporters that invested in the talent after that date" do
          expect(user.supporters(invested_after: date)).to match_array([supporter_two, user])
        end
      end
    end
  end

  describe "#portfolio" do
    let(:user) { create :user, wallet_id: wallet_id }
    let(:talent) { create :talent, user: user }
    let!(:talent_token) { create :talent_token, talent: talent }
    let(:wallet_id) { SecureRandom.hex }

    context "when the user does not have any investor" do
      it "returns an empty array" do
        expect(user.portfolio).to be_empty
      end
    end

    context "when the user does not have the wallet connected" do
      let(:wallet_id) { nil }

      it "returns an empty array" do
        expect(user.portfolio).to be_empty
      end
    end

    context "when the user has some investments" do
      let(:talent_user_one) { create :user }
      let(:talent_one) { create :talent, user: talent_user_one }
      let!(:talent_token_one) { create :talent_token, talent: talent_one }

      let(:talent_user_two) { create :user }
      let!(:talent_two) { create :talent, user: talent_user_two }
      let!(:talent_token_two) { create :talent_token, talent: talent_two }

      let(:talent_user_three) { create :user }
      let!(:talent_three) { create :talent, user: talent_user_three }
      let!(:talent_token_three) { create :talent_token, talent: talent_three }

      before do
        create :talent_supporter, supporter_wallet_id: wallet_id, talent_contract_id: talent_token_one.contract_id, last_time_bought_at: Date.today - 10.days
        create :talent_supporter, supporter_wallet_id: wallet_id, talent_contract_id: talent_token_two.contract_id, last_time_bought_at: Date.today - 5.days
        create :talent_supporter, supporter_wallet_id: SecureRandom.hex, talent_contract_id: talent_token_three, last_time_bought_at: Date.today - 2.days
        create :talent_supporter, supporter_wallet_id: wallet_id, talent_contract_id: talent_token.contract_id, last_time_bought_at: Date.today
      end

      it "returns the users in which the user invested" do
        expect(user.portfolio).to match_array([user, talent_user_one, talent_user_two])
      end

      context "when including_self is passed as false" do
        it "returns the users that support him expect himself" do
          expect(user.portfolio(including_self: false)).to match_array([talent_user_one, talent_user_two])
        end
      end

      context "when invested_after is passed" do
        let(:date) { Date.today - 6.days }

        it "returns the portfolio that invested in the talent after that date" do
          expect(user.portfolio(invested_after: date)).to match_array([talent_user_two, user])
        end
      end
    end
  end

  describe "#connected_with_since" do
    let(:user) { create :user }

    let(:other_user) { create :user, talent: talent }
    let(:talent) { create :talent }
    let(:talent_token) { create :talent_token, talent: talent, deployed: true }

    context "when the user is only following the other user" do
      before do
        create :follow, user: other_user, follower: user, created_at: Date.yesterday
      end

      it "returns the date of the follow" do
        expect(user.connected_with_since(other_user)).to eq Date.yesterday
      end
    end

    context "when the user is only invested in the other user" do
      before do
        create :talent_supporter, supporter_wallet_id: user.wallet_id, talent_contract_id: talent_token.contract_id, first_time_bought_at: Date.today - 10.days
      end

      it "returns the date of the first investment" do
        expect(user.connected_with_since(other_user)).to eq Date.today - 10.days
      end
    end

    context "when the user is invested in and is following the other user" do
      before do
        create :follow, user: other_user, follower: user, created_at: Date.yesterday
        create :talent_supporter, supporter_wallet_id: user.wallet_id, talent_contract_id: talent_token.contract_id, first_time_bought_at: Date.today - 10.days
      end

      it "returns the date the oldest date" do
        expect(user.connected_with_since(other_user)).to eq Date.today - 10.days
      end
    end
  end

  describe "#valid_delete_account_token?" do
    let(:user) { create :user, delete_account_token: token, delete_account_token_expires_at: expires_at }
    let(:expires_at) { Time.now + 1.hour }
    let(:token) { "token" }

    it "returns true" do
      expect(user.valid_delete_account_token?("token"))
    end

    context "when the tokens do not match" do
      it "returns false" do
        expect(user.valid_delete_account_token?("invalid-token"))
      end
    end

    context "when the token has expired" do
      let(:expires_at) { Time.now - 1.hour }

      it "returns false" do
        expect(user.valid_delete_account_token?("token"))
      end
    end

    context "when the user does not have a delete account token and expiry" do
      let(:expires_at) { nil }
      let(:token) { nil }

      it "returns false" do
        expect(user.valid_delete_account_token?("token"))
      end
    end
  end

  describe "#moderator?" do
    let(:user) { create :user, role: role }

    context "when the user's role is 'admin'" do
      let(:role) { "admin" }

      it "returns false" do
        expect(user.moderator?).to be_falsey
      end
    end

    context "when the user's role is 'basic'" do
      let(:role) { "basic" }

      it "returns false" do
        expect(user.moderator?).to be_falsey
      end
    end

    context "when the user's role is 'moderator'" do
      let(:role) { "moderator" }

      it "returns true" do
        expect(user.moderator?).to be_truthy
      end
    end
  end
end
