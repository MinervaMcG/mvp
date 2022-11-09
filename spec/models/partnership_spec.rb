require "rails_helper"

RSpec.describe Partnership, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:invited).optional }

    it { is_expected.to have_many(:invites) }

    it { is_expected.to have_one(:discovery_row) }
  end

  describe "validations" do
    subject { build :partnership }

    it do
      is_expected
        .to allow_values("https://foo.com", "https://bar.com")
        .for(:button_url)
    end

    it { is_expected.not_to allow_values("foo", "buz").for(:button_url) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }

    it do
      is_expected
        .to allow_values("https://foo.com", "http://bar.com", "")
        .for(:twitter_url)
    end

    it { is_expected.not_to allow_values("foo", "buz").for(:twitter_url) }

    it do
      is_expected
        .to allow_values("https://foo.com", "http://bar.com", "")
        .for(:website_url)
    end

    it { is_expected.not_to allow_values("foo", "buz").for(:website_url) }
  end
end
