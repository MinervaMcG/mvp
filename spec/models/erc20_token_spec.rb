require "rails_helper"

RSpec.describe Erc20Token, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { build :erc20_token }

    it { is_expected.to validate_presence_of(:address) }
  end
end
