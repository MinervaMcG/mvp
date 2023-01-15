require "rails_helper"

RSpec.describe WithPersona::FailedInquiry do
  subject(:failed_inquiry) do
    described_class.new(talent: talent).call
  end

  let(:user) { create :user }
  let!(:talent) { create :talent, user: user, verified: false, with_persona_id: "123" }
  let(:create_notification_class) { CreateNotification }
  let(:create_notification_instance) { instance_double(create_notification_class, call: true) }

  before do
    allow(create_notification_class).to receive(:new).and_return(create_notification_instance)
  end

  it "clears the with persona field" do
    failed_inquiry

    expect(talent.reload.with_persona_id).to eq nil
  end

  it "initializes and calls the notification service" do
    failed_inquiry

    expect(create_notification_class).to have_received(:new)
    expect(create_notification_instance).to have_received(:call).with(
      recipient: user,
      source_id: user.id,
      type: UserPersonaVerificationFailedNotification,
      extra_params: {reason: "with_persona", with_persona_id: "123"}
    )
  end
end
