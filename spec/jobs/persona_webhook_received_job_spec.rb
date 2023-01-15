require "rails_helper"

RSpec.describe PersonaWebhookReceivedJob, type: :job do
  subject(:persona_webhook_job) { PersonaWebhookReceivedJob.perform_now(params: params["data"].to_h) }

  let!(:current_month_persona_request) { create :with_persona_request, month: Date.today.month, year: Date.today.year, requests_counter: 20 }

  context "when it is a verification created event" do
    let(:params) do
      JSON.parse(file_fixture("persona_webhook_verification_created_body.json").read)
    end

    it "increases the number of requests by 1" do
      persona_webhook_job

      expect(current_month_persona_request.reload.requests_counter).to eq(21)
    end
  end

  context "when it is an approved inquiry event" do
    let(:params) do
      JSON.parse(file_fixture("persona_webhook_inquiry_approved_body.json").read)
    end

    let(:approve_inquiry_class) { WithPersona::ApproveInquiry }
    let(:approved_inquiry_instance) { instance_double(approve_inquiry_class, call: true) }

    before do
      allow(approve_inquiry_class).to receive(:new).and_return(approved_inquiry_instance)
    end

    context "when there's a talent matching the inquiry id" do
      let!(:talent) { create :talent, with_persona_id: "inq_de7ZZTn3r7yTecY8Z1ybEBEc" }

      it "initializes and calls the approve inquiry service" do
        persona_webhook_job

        expect(approve_inquiry_class).to have_received(:new).with(
          talent: talent,
          inquiry_first_name: "ruben",
          inquiry_last_name: "dinis"
        )
        expect(approved_inquiry_instance).to have_received(:call)
      end
    end

    context "when there's no talent matching the inquiry id" do
      it "raises an error" do
        expect { persona_webhook_job }.to raise_error(
          ActiveRecord::RecordNotFound
        )

        expect(approve_inquiry_class).not_to have_received(:new)
      end
    end
  end

  context "when it is a failed inquiry event" do
    let(:params) do
      JSON.parse(file_fixture("persona_webhook_inquiry_failed_body.json").read)
    end

    let(:failed_inquiry_class) { WithPersona::FailedInquiry }
    let(:failed_inquiry_instance) { instance_double(failed_inquiry_class, call: true) }

    before do
      allow(failed_inquiry_class).to receive(:new).and_return(failed_inquiry_instance)
    end

    context "when there's a talent matching the inquiry id" do
      let!(:talent) { create :talent, with_persona_id: "inq_de7ZZTn3r7yTecY8Z1ybEBEc" }

      it "initializes and calls the failed inquiry service" do
        persona_webhook_job

        expect(failed_inquiry_class).to have_received(:new).with(
          talent: talent
        )
        expect(failed_inquiry_instance).to have_received(:call)
      end
    end

    context "when there's no talent matching the inquiry id" do
      it "raises an error" do
        expect { persona_webhook_job }.to raise_error(
          ActiveRecord::RecordNotFound
        )

        expect(failed_inquiry_class).not_to have_received(:new)
      end
    end
  end
end
