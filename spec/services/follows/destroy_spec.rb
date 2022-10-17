require "rails_helper"

RSpec.describe Follows::Destroy do
  include ActiveJob::TestHelper

  subject(:delete_follow) { described_class.new(follow: follow).call }

  let!(:follow) { create :follow, user: following_user, follower: follower_user }

  let(:follower_user) { create :user }
  let(:following_user) { create :user }

  it "deletes the follow" do
    expect { delete_follow }.to change(Follow, :count).from(1).to(0)
  end

  context "when there are connections related with the follow" do
    before do
      create :connection, user: following_user, connected_user: follower_user, connection_type: "follower"
      create :connection, user: follower_user, connected_user: following_user, connection_type: "following"
    end

    it "deletes the connections" do
      expect { delete_follow }.to change(Connection, :count).from(2).to(0)
    end
  end

  context "when there are connections related with the follow" do
    before do
      create :connection, user: following_user, connected_user: follower_user, connection_type: "follower"
      create :connection, user: follower_user, connected_user: following_user, connection_type: "following"
    end

    it "deletes the connections" do
      expect { delete_follow }.to change(Connection, :count).from(2).to(0)
    end
  end

  context "when there is a stronger connection between the users" do
    before do
      talent = create :talent, user: following_user
      token = create :talent_token, talent: talent, deployed: true
      create(
        :talent_supporter,
        supporter_wallet_id: follower_user.wallet_id,
        talent_contract_id: token.contract_id,
        amount: "1000000",
        first_time_bought_at: Date.yesterday
      )

      create :connection, user: following_user, connected_user: follower_user, connection_type: "supporter"
      create :connection, user: follower_user, connected_user: following_user, connection_type: "supporting"
    end

    it "deletes the connections" do
      expect { delete_follow }.not_to change(Connection, :count)
    end
  end
end
