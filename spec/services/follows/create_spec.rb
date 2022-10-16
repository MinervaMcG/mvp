require "rails_helper"

RSpec.describe Follows::Create do
  include ActiveJob::TestHelper

  subject(:create_follow) { described_class.new(following_user: following_user, follower_user: follower_user).call }

  let(:follower_user) { create :user }
  let(:following_user) { create :user }

  it "creates a new follow" do
    expect { create_follow }.to change(Follow, :count).from(0).to(1)
  end

  it "creates two connections" do
    expect { create_follow }.to change(Connection, :count).from(0).to(2)
  end

  it "creates the follow with the correct arguments" do
    created_follow = create_follow

    aggregate_failures do
      expect(created_follow.user).to eq(following_user)
      expect(created_follow.follower).to eq(follower_user)
    end
  end

  it "creates the connections with the correct arguments" do
    create_follow

    follower_connection = follower_user.connections.last
    following_connection = following_user.connections.last

    aggregate_failures do
      expect(follower_connection.user).to eq(follower_user)
      expect(follower_connection.connected_user).to eq(following_user)
      expect(follower_connection.connection_type).to eq("follower")

      expect(following_connection.user).to eq(following_user)
      expect(following_connection.connected_user).to eq(follower_user)
      expect(following_connection.connection_type).to eq("following")
    end
  end

  context "when the follow already exists" do
    before { create :follow, follower: follower_user, user: following_user }

    it "raises an error" do
      expect { create_follow }.to raise_error(described_class::AlreadyExistsError)
    end
  end

  context "when there's a stronger connection in place" do
    before do
      talent = create :talent, user: following_user
      token = create :talent_token, talent: talent, deployed: true
      create :talent_supporter, supporter_wallet_id: follower_user.wallet_id, talent_contract_id: token.contract_id, amount: "1000000", first_time_bought_at: Date.yesterday
    end

    it "creates two connections" do
      expect { create_follow }.to change(Connection, :count).from(0).to(2)
    end

    it "creates the connections with the correct arguments" do
      create_follow

      follower_connection = follower_user.connections.last
      following_connection = following_user.connections.last

      aggregate_failures do
        expect(follower_connection.user).to eq(follower_user)
        expect(follower_connection.connected_user).to eq(following_user)
        expect(follower_connection.connection_type).to eq("supporting")

        expect(following_connection.user).to eq(following_user)
        expect(following_connection.connected_user).to eq(follower_user)
        expect(following_connection.connection_type).to eq("supporter")
      end
    end
  end

  context "when the user has more than 2 follows" do
    before do
      create :follow, user: create(:user), follower: follower_user
      create :follow, user: create(:user), follower: follower_user
    end

    it "enqueues the job to update the watchlist task" do
      Sidekiq::Testing.inline! do
        create_follow

        job = enqueued_jobs[0]

        aggregate_failures do
          expect(job["job_class"]).to eq("UpdateTasksJob")
          expect(job["arguments"][0]["type"]).to eq("Tasks::Watchlist")
          expect(job["arguments"][0]["user_id"]).to eq(follower_user.id)
        end
      end
    end
  end
end
