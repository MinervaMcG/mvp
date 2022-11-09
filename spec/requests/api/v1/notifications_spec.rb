require "rails_helper"

RSpec.describe "Notifications", type: :request do
  let(:current_user) { create :user }

  describe "#index" do
    subject(:get_notifications) { get api_v1_notifications_path(as: current_user) }

    let!(:notification_one) { create :notification, recipient: current_user, type: "TalentChangedNotification" }
    let!(:notification_two) { create :notification, recipient: current_user, type: "QuestCompletedNotification" }
    let!(:notification_three) { create :notification, recipient: create(:user), type: "TokenAcquiredNotification" }

    it "returns a successful response" do
      get_notifications

      expect(response).to have_http_status(:ok)
    end

    it "returns the notifications of the user" do
      get_notifications

      expect(json[:notifications].map(&:with_indifferent_access)).to match_array(
        NotificationBlueprint.render_as_json([notification_one, notification_two], view: :normal)
      )
    end

    it "returns pagination data" do
      get_notifications

      expect(json[:pagination]).to eq(
        {
          currentPage: 1,
          lastPage: 1
        }
      )
    end
  end

  describe "#mark_all_as_read" do
    subject(:mark_all_as_read) { post api_v1_clear_notifications_path(as: current_user) }

    let!(:notification_one) { create :notification, recipient: current_user, type: "TalentChangedNotification" }
    let!(:notification_two) { create :notification, recipient: current_user, type: "QuestCompletedNotification", read_at: Date.yesterday }
    let!(:notification_three) { create :notification, recipient: create(:user), type: "TokenAcquiredNotification" }

    it "returns a successful response" do
      mark_all_as_read

      expect(response).to have_http_status(:ok)
    end

    it "marks all user notifications as read" do
      freeze_time do
        mark_all_as_read

        notification_one.reload
        notification_two.reload
        notification_three.reload

        aggregate_failures do
          expect(notification_one.read_at).to eq Time.now
          expect(notification_two.read_at).to eq Date.yesterday
          expect(notification_three.read_at).to eq nil
        end
      end
    end
  end

  describe "#mark_as_read" do
    subject(:mark_as_read) { put api_v1_notification_mark_as_read_path(notification_id: notification.id, as: current_user) }

    let!(:notification) { create :notification, recipient: current_user, type: "TalentChangedNotification" }

    it "returns a successful response" do
      mark_as_read

      expect(response).to have_http_status(:ok)
    end

    it "marks all user notifications as read" do
      freeze_time do
        mark_as_read

        notification.reload

        aggregate_failures do
          expect(notification.read_at).to eq Time.now
        end
      end
    end
  end
end
