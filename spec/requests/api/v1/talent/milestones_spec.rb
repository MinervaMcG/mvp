require "rails_helper"

RSpec.describe "Milestones", type: :request do
  let(:current_user) { create :user }
  let(:talent) { create :talent, user: current_user }

  describe "#update" do
    let!(:milestone) { create :milestone, talent: talent }
    subject(:update_milestone_request) {
      patch api_v1_talent_milestone_path(
        talent_id: talent.id,
        id: milestone.id,
        params: params,
        as: current_user
      )
    }

    let(:params) do
      {
        milestone: {
          title: "New title",
          start_date: "01-09-2022",
          end_date: nil,
          institution: "Talent Protocol",
          description: "New entry",
          category: "Position",
          in_progress: false,
          images: [""]
        }
      }
    end

    context "when the current user does not match the user's milestone passed" do
      let(:another_user) { create :user }

      it "returns an authorization error" do
        put api_v1_talent_milestone_path(
          talent_id: talent.id,
          id: milestone.id,
          params: params,
          as: another_user
        )

        expect(response).to have_http_status(:unauthorized)
      end

      it "renders the appropriate error message" do
        put api_v1_talent_milestone_path(
          talent_id: talent.id,
          id: milestone.id,
          params: params,
          as: another_user
        )

        expect(json).to eq(
          {
            error: "You don't have access to perform that action"
          }
        )
      end
    end

    context "when the params are all valid" do
      it "returns a successful response" do
        update_milestone_request

        expect(response).to have_http_status(:ok)
      end

      it "updates the milestone" do
        update_milestone_request

        milestone.reload

        aggregate_failures do
          expect(milestone.title).to eq "New title"
          expect(milestone.start_date).to eq "01-09-2022".to_date
          expect(milestone.end_date).to eq nil
          expect(milestone.description).to eq "New entry"
          expect(milestone.link).to eq nil
          expect(milestone.institution).to eq "Talent Protocol"
          expect(milestone.category).to eq "Position"
          expect(milestone.in_progress).to eq false
        end
      end
    end
  end

  describe "#create" do
    subject(:create_milestone_request) {
      post api_v1_talent_milestones_path(
        talent_id: talent.id,
        params: params,
        as: current_user
      )
    }

    let(:params) do
      {
        milestone: {
          title: "New title",
          start_date: "01-09-2022",
          end_date: nil,
          institution: "Talent Protocol",
          description: "New entry",
          category: "Position",
          in_progress: false,
          images: [""]
        }
      }
    end

    context "when the current user does not match the user's milestone passed" do
      let(:another_user) { create :user }

      it "returns an authorization error" do
        post api_v1_talent_milestones_path(
          talent_id: talent.id,
          params: params,
          as: another_user
        )

        expect(response).to have_http_status(:unauthorized)
      end

      it "renders the appropriate error message" do
        post api_v1_talent_milestones_path(
          talent_id: talent.id,
          params: params,
          as: another_user
        )

        expect(json).to eq(
          {
            error: "You don't have access to perform that action"
          }
        )
      end
    end

    context "when the params are all valid" do
      it "returns a successful response" do
        create_milestone_request

        expect(response).to have_http_status(:created)
      end

      it "creates the milestone" do
        create_milestone_request

        aggregate_failures do
          expect(json[:title]).to eq "New title"
          expect(json[:start_date]).to eq "2022-09-01"
          expect(json[:end_date]).to eq nil
          expect(json[:description]).to eq "New entry"
          expect(json[:link]).to eq nil
          expect(json[:institution]).to eq "Talent Protocol"
          expect(json[:category]).to eq "Position"
          expect(json[:in_progress]).to eq false
        end
      end
    end
  end
end
