require "rails_helper"

RSpec.describe "Talent Tokens", type: :request do
  let(:current_user) { create :user }

  describe "#update" do
    let!(:talent) { create :talent, user: current_user }
    subject(:update_talent_token_request) { put api_v1_talent_token_path(talent_id: talent.id, id: talent_token.id, params: params, as: current_user) }

    let(:params) do
      {
        talent_token: {
          contract_id: contract_id,
          deployed: deployed
        }
      }
    end

    context "when the talent token is not deployed" do
      let!(:talent_token) { create :talent_token, talent: talent, deployed: false, deployed_at: nil }

      context "when the talent token is deployed" do
        let(:contract_id) { SecureRandom.hex }
        let(:deployed) { true }

        it "sets the deployed_at field" do
          freeze_time do
            update_talent_token_request

            expect(talent_token.reload.deployed_at).to eq(Time.zone.now)
          end
        end

        it "updates the talent to be public" do
          update_talent_token_request

          talent.reload
          expect(talent.public).to eq(true)
          expect(talent.total_supply).to eq(Talent.base_supply.to_s)
          expect(talent.supporters_count).to eq(0)
        end
      end
    end
  end
end
