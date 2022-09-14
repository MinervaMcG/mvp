require "rails_helper"

RSpec.describe Users::UpdateProfileType do
  subject(:update_profile_type) { described_class.new.call(params) }

  let(:user) { create :user }
  let(:admin) { create :user, role: "admin" }

  let(:params) {
    {
      user: user,
      new_profile_type: new_profile_type,
      who_dunnit_id: who_dunnit_id,
      note: note
    }
  }

  let(:user_id) { user.id }
  let(:who_dunnit_id) { nil }
  let(:note) { nil }
  let(:new_profile_type) { "waiting_for_approval" }

  context "when a valid profile_type is provided" do
    it "it updates the profile_type" do
      result = update_profile_type

      expect(result.user_id).to be(user.id)
      expect(result.who_dunnit_id).to be(user.id)
      expect(result.new_profile_type).to eq(new_profile_type)
    end
  end

  context "when an invalid profile_type is provided" do
    let(:new_profile_type) { "gibberish" }

    before do
      allow(Rollbar).to receive(:error)
    end

    it "it fails to update the profile_type" do
      update_profile_type

      expect(Rollbar).to have_received(:error)
    end
  end

  context "when the user tries to update their profile_type to approved" do
    let(:new_profile_type) { "approved" }

    before do
      allow(Rollbar).to receive(:error)
    end

    it "it fails to update the profile_type" do
      update_profile_type

      expect(Rollbar).to have_received(:error)
    end
  end

  context "when the user tries to update their profile_type to talent from other than approved" do
    let(:user) { create :user, profile_type: "waiting_for_approval" }
    let(:new_profile_type) { "approved" }

    before do
      allow(Rollbar).to receive(:error)
    end

    it "it fails to update the profile_type" do
      update_profile_type

      expect(Rollbar).to have_received(:error)
    end
  end

  context "when an admin updates the user" do
    let(:who_dunnit_id) { admin.id }

    it "it updates the profile_type" do
      result = update_profile_type

      expect(result.user_id).to be(user.id)
      expect(result.who_dunnit_id).to be(admin.id)
      expect(result.new_profile_type).to eq(new_profile_type)
    end
  end

  context "when the user is approved" do
    let(:new_profile_type) { "approved" }
    let(:who_dunnit_id) { admin.id }

    it "creates a new notification" do
      expect { update_profile_type }.to change(Notification, :count).from(0).to(1)
    end

    it "enqueues a job to send the notification by email" do
      expect { update_profile_type }.to have_enqueued_job(Noticed::DeliveryMethods::Email)
    end

    it "creates the new notification with the correct params" do
      update_profile_type

      new_notification = Notification.last

      expect(new_notification.params).to eq({
        "source_id" => who_dunnit_id
      })
      expect(new_notification.type).to eq("TalentApplicationApprovedNotification")
    end
  end

  context "when the user is rejected" do
    let(:new_profile_type) { "rejected" }
    let(:note) { "Your profile needs to be improved." }
    let(:who_dunnit_id) { admin.id }

    it "it updates the profile_type" do
      result = update_profile_type

      expect(result.user_id).to be(user.id)
      expect(result.who_dunnit_id).to be(who_dunnit_id)
      expect(result.note).to eq("Your profile needs to be improved.")
      expect(result.new_profile_type).to eq("rejected")
    end

    it "creates a new notification" do
      expect { update_profile_type }.to change(Notification, :count).from(0).to(1)
    end

    it "enqueues a job to send the notification by email" do
      expect { update_profile_type }.to have_enqueued_job(Noticed::DeliveryMethods::Email)
    end

    it "creates the new notification with the correct params" do
      update_profile_type

      new_notification = Notification.last

      expect(new_notification.params).to eq({
        "source_id" => who_dunnit_id,
        "note" => "Your profile needs to be improved."
      })
      expect(new_notification.type).to eq("TalentApplicationRejectedNotification")
    end
  end
end
