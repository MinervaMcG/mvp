require "rails_helper"

RSpec.describe FeedPost, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:feed) }
    it { is_expected.to belong_to(:post) }
  end
end
