require "rails_helper"

RSpec.describe "Perks", type: :request do
  let(:current_user) { create :user }

  describe "#perks" do
    subject(:get_perks) { get api_v1_user_profile_perks_path(user_id: current_user.id, as: current_user) }

    context "when the current user is a talent" do
      let!(:talent) { create :talent, user: current_user }

      let!(:perk_1) { create :perk, talent: talent, title: "Perk 1" }
      let!(:perk_2) { create :perk, talent: create(:talent), title: "Perk 2" }
      let!(:perk_3) { create :perk, talent: talent, title: "Perk 3" }

      it "returns a successful response" do
        get_perks

        expect(response).to have_http_status(:ok)
      end

      it "only returns perks of the talent" do
        get_perks

        expect(json[:perks]).to eq [
          {
            id: perk_1.id,
            price: perk_1.price,
            title: perk_1.title
          },
          {
            id: perk_3.id,
            price: perk_3.price,
            title: perk_3.title
          }
        ]
      end
    end

    context "when the current user is not a talent" do
      it "returns a not found response" do
        get_perks

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
