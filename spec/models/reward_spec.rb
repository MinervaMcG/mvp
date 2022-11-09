require "rails_helper"

RSpec.describe Reward, type: :model do
  subject { build :reward, user: build(:user) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:creator).optional(true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_uniqueness_of(:identifier) }
  end
end
