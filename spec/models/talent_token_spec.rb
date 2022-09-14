require "rails_helper"

RSpec.describe TalentToken, type: :model do
  subject { build :talent_token, ticker: "TALENT" }

  describe "associations" do
    it { is_expected.to belong_to(:talent) }
  end

  describe "validations" do
    context "when the ticker has less than 2 chars" do
      it "show the correct error message" do
        subject.update(ticker: "DI")

        expect(subject.errors.full_messages).to eq ["Ticker is too short (minimum is 3 characters)"]
      end
    end

    context "when the ticker has more than 8 chars" do
      it "show the correct error message" do
        subject.update(ticker: "SOUSADINIS")

        expect(subject.errors.full_messages).to eq ["Ticker is too long (maximum is 8 characters)"]
      end
    end

    context "when there is an existing token with the same ticker" do
      before do
        create :talent_token, ticker: "DINIS"
      end

      it "show the correct error message" do
        subject.update(ticker: "DINIS")

        expect(subject.errors.full_messages).to eq ["Ticker already taken."]
      end
    end
  end
end
