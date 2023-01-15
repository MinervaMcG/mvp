require "rails_helper"

RSpec.describe "Profiles", type: :request do
  describe "#show" do
    subject(:get_profile) { get profile_path(username: username, as: current_user) }

    let(:user) { create :user }
    let!(:talent) { create :talent, user: user }
    let(:username) { user.username }
    let(:current_user) { user }
    let!(:with_persona_request) { create :with_persona_request, month: Date.today.month, year: Date.today.year }

    context "when the current user is admin" do
      before do
        current_user.update(role: "admin")
      end

      it "returns a successful response" do
        get_profile

        expect(response).to have_http_status(:ok)
      end

      it "assigns the correct profile to be passed to the view" do
        get_profile

        expect(assigns(:talent)).to eq(TalentBlueprint.render_as_json(talent, view: :extended))
      end

      it "assigns the correct with_persona_request to be passed to the view" do
        get_profile

        expect(assigns(:with_persona_request)).to eq(
          WithPersonaRequestBlueprint.render_as_json(with_persona_request)
        )
      end
    end
  end
end
