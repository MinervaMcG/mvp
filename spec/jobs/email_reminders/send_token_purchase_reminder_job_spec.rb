require "rails_helper"

RSpec.describe EmailReminders::SendTokenPurchaseReminderJob, type: :job do
  include ActiveJob::TestHelper

  subject(:token_purchase_reminder) { described_class.perform_now }
  let(:user) { create :user }

  before do
    ENV["EMAIL_REMINDER_DAYS"] = "7"
  end

  context "supporter created 8 days ago" do
    before do
      @talent = create :talent, created_at: 8.days.ago, user: user
    end

    it "should send email if no token is purchased" do
      Sidekiq::Testing.inline! do
        token_purchase_reminder
        perform_enqueued_jobs
        expect(ActionMailer::Base.deliveries.count).to eq 1
      end
    end

    it "should not send email if token is purchased" do
      talent_token = create :talent_token
      create :talent_supporter, supporter_wallet_id: @talent.wallet_id, talent_contract_id: talent_token.contract_id

      Sidekiq::Testing.inline! do
        token_purchase_reminder
        perform_enqueued_jobs
        expect(ActionMailer::Base.deliveries.count).to eq 0
      end
    end
  end

  it "should not send email supporters created before 7 days" do
    create :talent, user: user

    Sidekiq::Testing.inline! do
      token_purchase_reminder
      perform_enqueued_jobs
      expect(ActionMailer::Base.deliveries.count).to eq 0
    end
  end
end
