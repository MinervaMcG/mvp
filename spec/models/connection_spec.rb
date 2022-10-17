require "rails_helper"

RSpec.describe Connection, type: :model do
  subject { build :connection, user: build(:user), connected_user: build(:user) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:connected_user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:connected_at) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:connected_user_id) }
  end

  describe "#refresh_connection!" do
    let(:user) { create :user }
    let(:connected_user) { create :user }
    let!(:connection) { create :connection, user: user, connected_user: connected_user, connected_at: Date.yesterday }

    context "when there is no connection between the users" do
      it "deletes the existing connection" do
        expect { connection.refresh_connection! }.to change(Connection, :count).from(1).to(0)
      end
    end

    context "when the user is following the connected user" do
      before do
        create :follow, user: connected_user, follower: user
      end

      it "updates the connection type to follower" do
        updated_connection = connection.refresh_connection!

        expect(updated_connection.connection_type).to eq "follower"
      end
    end

    context "when the user is followed the connected user" do
      before do
        create :follow, user: user, follower: connected_user
      end

      it "updates the connection type to following" do
        updated_connection = connection.refresh_connection!

        expect(updated_connection.connection_type).to eq "following"
      end
    end

    context "when the user is supporting the connected user" do
      before do
        talent = create :talent, user: connected_user
        token = create :talent_token, talent: talent, deployed: true
        create :talent_supporter, supporter_wallet_id: user.wallet_id, talent_contract_id: token.contract_id, amount: "1000000", first_time_bought_at: Date.yesterday
      end

      it "updates the connection type to supporting" do
        updated_connection = connection.refresh_connection!

        expect(updated_connection.connection_type).to eq "supporting"
      end
    end

    context "when the user is supported the connected user" do
      before do
        talent = create :talent, user: user
        token = create :talent_token, talent: talent, deployed: true
        create :talent_supporter, supporter_wallet_id: connected_user.wallet_id, talent_contract_id: token.contract_id, amount: "1000000", first_time_bought_at: Date.yesterday
      end

      it "updates the connection type to supporter" do
        updated_connection = connection.refresh_connection!

        expect(updated_connection.connection_type).to eq "supporter"
      end
    end

    context "when the users are supported by each other" do
      before do
        talent_one = create :talent, user: user
        token_one = create :talent_token, talent: talent_one, deployed: true

        talent_two = create :talent, user: connected_user
        token_two = create :talent_token, talent: talent_two, deployed: true

        create :talent_supporter, supporter_wallet_id: connected_user.wallet_id, talent_contract_id: token_one.contract_id, amount: "1000000", first_time_bought_at: Date.yesterday
        create :talent_supporter, supporter_wallet_id: user.wallet_id, talent_contract_id: token_two.contract_id, amount: "1000000", first_time_bought_at: Date.yesterday
      end

      it "updates the connection type to super connection" do
        updated_connection = connection.refresh_connection!

        expect(updated_connection.connection_type).to eq "super_connection"
      end
    end
  end
end
