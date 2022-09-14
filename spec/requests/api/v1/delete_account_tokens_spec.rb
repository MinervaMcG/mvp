require "rails_helper"

RSpec.describe "DeleteAccountTokens", type: :request do
  let(:current_user) { create :user }

  describe "#create" do
    let(:user_id) { current_user.id }

    let(:delete_account_token_creator_class) { Users::CreateDeleteAccountToken }

    let(:delete_account_token_creator) do
      instance_double(delete_account_token_creator_class, call: result)
    end

    let(:result) { {success: success?} }
    let(:success?) { true }

    before do
      allow(delete_account_token_creator_class)
        .to receive(:new)
        .and_return(delete_account_token_creator)
    end

    subject(:create_delete_account_token) do
      post api_v1_user_delete_account_tokens_path(user_id: user_id, as: current_user)
    end

    it "initialises and calls the delete account token creator with the user" do
      create_delete_account_token

      aggregate_failures do
        expect(delete_account_token_creator_class)
          .to have_received(:new)
          .with(user: current_user)

        expect(delete_account_token_creator)
          .to have_received(:call)
      end
    end

    it "returns a created status with a success message" do
      create_delete_account_token

      aggregate_failures do
        expect(response).to have_http_status(:created)

        expect(response.body)
          .to eq({success: "Delete account token created successfully"}.to_json)
      end
    end

    context "when the delete account token creator returns an unsuccess result" do
      let(:success?) { false }

      it "returns an unprocessable entity status with an unsuccess message" do
        create_delete_account_token

        aggregate_failures do
          expect(response)
            .to have_http_status(:unprocessable_entity)

          expect(response.body)
            .to eq({error: "Unable to create delete account token"}.to_json)
        end
      end
    end

    context "when the user in the param is not the current user" do
      let(:user_id) { (create :user).id }

      it "returns an unprocessable entity status with an unsuccess message" do
        create_delete_account_token

        aggregate_failures do
          expect(response)
            .to have_http_status(:unauthorized)

          expect(response.body)
            .to eq({error: "You don't have access to perform that action"}.to_json)
        end
      end
    end
  end
end
