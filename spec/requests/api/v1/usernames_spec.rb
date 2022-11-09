require "rails_helper"

RSpec.describe "Usernames", type: :request do
  describe "#valid" do
    subject(:valid_username) { get valid_api_v1_username_path(username: username) }

    let(:username) { "testusername" }

    context "when the username is valid and not taken" do
      it "returns a successful response" do
        valid_username

        expect(response).to have_http_status(:ok)
      end

      it "renders a valid response" do
        valid_username

        expect(json).to eq({error: ""})
      end
    end

    context "when the username is taken" do
      before do
        create :user, username: username
      end

      it "renders an invalid response" do
        valid_username

        expect(json).to eq({error: "Username already taken."})
      end
    end

    context "when the username is invalid" do
      let(:username) { "test--.." }

      it "renders an invalid response" do
        valid_username

        expect(json).to eq({error: "Username only allows lower case letters and numbers."})
      end
    end
  end
end
