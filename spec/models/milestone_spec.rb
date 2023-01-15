require "rails_helper"

RSpec.describe Milestone, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:talent) }
  end

  describe "validations" do
    describe "start and end date validation" do
      context "when the start date is before the end date" do
        it "does not raise an error" do
          expect {
            create(:milestone, start_date: Date.today, end_date: Date.tomorrow)
          }.not_to raise_error
        end
      end

      context "when there's no end date" do
        it "does not raise an error" do
          expect {
            create(:milestone, start_date: Date.today)
          }.not_to raise_error
        end
      end

      context "when the start date is after the end date" do
        it "raises an error" do
          expect {
            create(:milestone, start_date: Date.tomorrow, end_date: Date.today)
          }.to raise_error(
            ActiveRecord::RecordInvalid,
            "Validation failed: Start date needs to be before the end date"
          )
        end
      end
    end
  end
end
