require "rails_helper"

RSpec.describe Talents::PolygonLaunchReward do
  let(:talent_token) { create :talent_token, talent: talent, chain_id: 80001, deployed_at: Time.now }
  let(:talent) { create :talent, user: user }
  let(:user) { create :user }

  subject(:polygon_launch_reward) { described_class.new }

  it "creates reward for talents who launched token on polygon" do
    expect { polygon_launch_reward.call(user) }.to change(Reward, :count).from(0).to(1)
  end
end
