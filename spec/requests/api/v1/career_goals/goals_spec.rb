require "rails_helper"

RSpec.describe "Goals", type: :request do
  let(:current_user) { create :user }
  let(:talent) { create :talent, user: current_user }
  let(:career_goal) { create :career_goal, talent: talent }

  describe "#update" do
    let!(:goal) { create :goal, career_goal: career_goal, due_date: Date.today }
    subject(:update_goal_request) {
      patch api_v1_career_goal_goal_path(
        career_goal_id: career_goal.id,
        id: goal.id,
        params: params,
        as: current_user
      )
    }

    let(:params) do
      {
        goal: {
          title: "New title",
          due_date: "01-09-2022",
          description: "New entry",
          images: [""]
        }
      }
    end

    context "when the current user does not match the user's goal passed" do
      let(:another_user) { create :user }
      let!(:another_talent) { create :talent, user: another_user }
      let!(:another_career_goal) { create :career_goal, talent: another_talent }

      it "returns an authorization error" do
        patch api_v1_career_goal_goal_path(
          career_goal_id: career_goal.id,
          id: goal.id,
          params: params,
          as: another_user
        )

        expect(response).to have_http_status(:unauthorized)
      end

      it "renders the appropriate error message" do
        patch api_v1_career_goal_goal_path(
          career_goal_id: career_goal.id,
          id: goal.id,
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
        update_goal_request

        expect(response).to have_http_status(:ok)
      end

      it "updates the goal" do
        update_goal_request

        goal.reload

        aggregate_failures do
          expect(goal.title).to eq "New title"
          expect(goal.due_date).to eq "01-09-2022".to_date
          expect(goal.description).to eq "New entry"
          expect(goal.link).to eq nil
        end
      end
    end
  end

  describe "#create" do
    subject(:create_goal_request) {
      post api_v1_career_goal_goals_path(
        career_goal_id: career_goal.id,
        params: params,
        as: current_user
      )
    }

    let(:params) do
      {
        goal: {
          title: "New title",
          due_date: "01-09-2022",
          description: "New entry",
          images: [""]
        }
      }
    end

    context "when the current user does not match the user's goal passed" do
      let(:another_user) { create :user }
      let!(:another_talent) { create :talent, user: another_user }
      let!(:another_career_goal) { create :career_goal, talent: another_talent }

      it "returns an authorization error" do
        post api_v1_career_goal_goals_path(
          career_goal_id: career_goal.id,
          params: params,
          as: another_user
        )

        expect(response).to have_http_status(:unauthorized)
      end

      it "renders the appropriate error message" do
        post api_v1_career_goal_goals_path(
          career_goal_id: career_goal.id,
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
        create_goal_request

        expect(response).to have_http_status(:created)
      end

      it "creates the goal" do
        create_goal_request

        aggregate_failures do
          expect(json[:title]).to eq "New title"
          expect(json[:due_date]).to eq "2022-09-01"
          expect(json[:description]).to eq "New entry"
          expect(json[:link]).to eq nil
        end
      end
    end
  end
end
