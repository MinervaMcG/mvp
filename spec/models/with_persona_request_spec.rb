require "rails_helper"

RSpec.describe WithPersonaRequest, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:month) }
    it { is_expected.to validate_presence_of(:year) }
  end

  describe ".current_month_persona_request" do
    context "when the current month request does not exist" do
      it "creates the current month request" do
        expect { WithPersonaRequest.current_month_persona_request }.to change(WithPersonaRequest, :count).from(0).to(1)
      end

      it "returns the current month request" do
        persona_request = WithPersonaRequest.current_month_persona_request

        expect(persona_request.month).to eq(Date.today.month)
        expect(persona_request.year).to eq(Date.today.year)
      end
    end

    context "when the current month request already exists" do
      let!(:current_month_persona_request) { create :with_persona_request, month: Date.today.month, year: Date.today.year }

      it "does not create a new presona request" do
        expect { WithPersonaRequest.current_month_persona_request }.not_to change(WithPersonaRequest, :count)
      end

      it "returns the current month request" do
        persona_request = WithPersonaRequest.current_month_persona_request

        expect(persona_request).to eq(current_month_persona_request)
      end
    end
  end
end
